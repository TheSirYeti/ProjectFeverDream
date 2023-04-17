using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Security;
using UnityEngine;

public abstract class Enemy : MonoBehaviour, ITakeDamage, IAttendance
{
    [Header("-== Base Properties ==-")]
    [SerializeField] protected float hp;
    [SerializeField] protected float maxHP;
    [Space(20)]

    [Header("-== Target Properties ==-")]
    [SerializeField] protected GameObject target;
    protected bool wasDetected = false;
    [SerializeField] private float minChaseDistance;

    [Space(20)] [Header("-== Attack Properties ==-")] 
    [SerializeField] protected Collider attackCollider;
    [SerializeField] protected float attackCooldown;
    [SerializeField] protected float currentAttackCooldown;
    [SerializeField] protected bool isAttacking;
    
    [Space(20)]
    [Header("-== Movement Properties ==-")] 
    [SerializeField] protected float speed;
    protected float maxSpeed;
    [SerializeField] private float accelerationValue;

    [Space(20)]
    [Header("-== Pathfinding Properties ==-")] 
    [SerializeField] protected List<Node> nodePath;
    protected int currentNode = 0;
    [SerializeField] private float minDistanceToNode;
    [SerializeField] protected bool isPathfinding;
    [SerializeField] protected float pathfindingCooldown, pathfindingRate;

    [Space(20)]
    [Header("-== Ragdoll Properties ==-")] 
    [SerializeField] private Rigidbody rb;
    [SerializeField] private bool hasRagdoll;
    protected bool isInRagdollMode = false;
    protected Rigidbody[] ragdollRigidbodies;
    //Temp
    [SerializeField] private Transform _bodyCenter;

    [Space(20)]
    [Header("-== View Properties ==-")]
    [SerializeField] protected Animator animator;
    [Space(20)] 
    [SerializeField] protected List<Renderer> renderers;
    
    protected Dictionary<string, float> _damageRecive = new Dictionary<string, float>();
    [Space(20)] 
    [Header("-== Hitpoints Properties ==-")]
    [SerializeField] protected float dmg;
    [Space(10)] 
    [SerializeField] protected float weakDmg, bodyDmg, headDmg, generalDmg;
    protected bool isDead = false;

    public abstract void Attack();
    
    #region RAGDOLLS

    public void DoRagdoll()
    {
        if (!hasRagdoll)
            return;
        
        isInRagdollMode = true;

        foreach (var rigidbody in ragdollRigidbodies)
        {
            rigidbody.isKinematic = false;
        }
        
        //collider.enabled = false;
        rb.isKinematic = true;
        animator.enabled = false;
    }

    public void StopRagdoll()
    {
        if (!hasRagdoll)
            return;
        
        isInRagdollMode = false;

        foreach (var rigidbody in ragdollRigidbodies)
        {
            rigidbody.isKinematic = true;
        }
        
        //collider.enabled = true;
        rb.isKinematic = false;
        animator.enabled = true;
    }

    #endregion

    #region MOVEMENT
    
    public abstract void Move();

    public void SetSpeedValue(float value)
    {
        if (speed >= maxSpeed)
        {
            speed = maxSpeed;
            return;
        }

        speed += value * accelerationValue;
    }

    protected void StopSpeed()
    {
        speed = 0;
    }
    
    protected void DoGenericChase()
    {
        transform.forward = target.transform.position - transform.position;
        
        transform.LookAt(new Vector3(target.transform.position.x, transform.position.y, target.transform.position.z));
        transform.position += transform.forward * speed * Time.deltaTime;
    }

    public void DoPathfinding()
    {
        Vector3 direction;
        if (isPathfinding && nodePath != null)
        {
            direction = nodePath[currentNode].transform.position - transform.position;
            //direction = new Vector3(direction.x, transform.position.y, direction.z).normalized;
            transform.forward = direction;
            transform.position += transform.forward * speed * Time.deltaTime;
            transform.LookAt(new Vector3(transform.forward.x, transform.position.y, transform.forward.z));
            
            if (direction.magnitude <= minDistanceToNode)
            {
                currentNode++;
                if (currentNode >= nodePath.Count)
                {
                    currentNode = 0;
                    isPathfinding = false;
                }
            }
        }
    }
    
    protected bool IsInDistance()
    {
        return Vector3.Distance(target.transform.position, transform.position) <= minChaseDistance;
    }

    #endregion

    #region PATHFINDING

    protected void CalculatePathPreview()
    {
        if ((!isPathfinding
             || nodePath == null
             || nodePath.Count < 1
             || NodeManager.instance.nodes[NodeManager.instance.GetClosestNode(target.transform)] !=
             nodePath[nodePath.Count - 1]) && pathfindingCooldown <= 0)
        {
            nodePath = new List<Node>();
            int closeNode = NodeManager.instance.GetClosestNode(transform);
            int endNode = NodeManager.instance.GetClosestNode(target.transform);

            string myNodes = closeNode + "," + endNode;

            List<Node> newPath = PathfindingTable.instance.ConstructPathThetaStar(myNodes);
            if (!newPath.Any())
                return;

            if (!nodePath.Any() || newPath[currentNode] != nodePath[currentNode] || currentNode > nodePath.Count - 1)
                currentNode = 0;

            int nodeCounter = 0;
            foreach (var node in newPath)
            {
                if (InSight(transform.position, node.transform.position))
                {
                    currentNode = nodeCounter;
                }
                nodeCounter++;
            }
            
            nodePath = newPath;
            isPathfinding = true;
        }
    }
    
    public List<Node> ConstructPathThetaStar(Node startingNode, Node goalNode)
    {
        var path = ConstructPathAStar(startingNode, goalNode);
        if (path != null)
        {
            path.Reverse();
            int index = 0;

            while (index <= path.Count - 1)
            {
                int indexNextNext = index + 2;
                if (indexNextNext > path.Count - 1) break;
                if (InSight(path[index].transform.position, path[indexNextNext].transform.position))
                    path.Remove(path[index + 1]);
                else index++;

            }
        }
        return path;
    }
    protected bool InSight(Vector3 start, Vector3 end)
    {
        Vector3 dir = end - start;
        if (!Physics.Raycast(start, dir, dir.magnitude, NodeManager.instance.wallMask)) return true;
        else return false;
    }

    public List<Node> ConstructPathAStar(Node startingNode, Node goalNode)
    {
        if (startingNode == null || goalNode == null)
            return default;

        PriorityQueue frontier = new PriorityQueue();
        frontier.Put(startingNode, 0);

        Dictionary<Node, Node> cameFrom = new Dictionary<Node, Node>();
        Dictionary<Node, int> costSoFar = new Dictionary<Node, int>();

        cameFrom.Add(startingNode, null);
        costSoFar.Add(startingNode, 0);

        while (frontier.Count() > 0)
        {
            Node current = frontier.Get();

            if (current == goalNode)
            {
                List<Node> path = new List<Node>();
                Node nodeToAdd = current;

                while (nodeToAdd != null)
                {
                    path.Add(nodeToAdd);
                    nodeToAdd = cameFrom[nodeToAdd];
                }

                return path;
            }

            foreach (var next in current.GetNeighbors())
            {
                int newCost = costSoFar[current] + next.cost;

                if (!costSoFar.ContainsKey(next) || newCost < costSoFar[next])
                {
                    if (costSoFar.ContainsKey(next))
                    {
                        costSoFar[next] = newCost;
                        cameFrom[next] = current;
                    }
                    else
                    {
                        cameFrom.Add(next, current);
                        costSoFar.Add(next, newCost);
                    }

                    float priority = newCost + Heuristic(next.transform.position, goalNode.transform.position);
                    frontier.Put(next, priority);
                }
            }
        }
        return default;
    }
    
    float Heuristic(Vector3 a, Vector3 b)
    {
        return Vector3.Distance(a, b);
    }

    #endregion
    
    #region DAMAGE / HEALTH
    
    public abstract void Death();
    
    private void OnTriggerEnter(Collider other)
    {
        IReciveDamage damagable = other.GetComponent<IReciveDamage>();

        if (damagable != null)
        {
            damagable.DoDamage(dmg, transform.position);
        }
    }
    
    public void TakeDamage(string partDamaged, float dmg, bool hasKnockback = false)
    {
        if (!_damageRecive.ContainsKey(partDamaged) || isInRagdollMode || isDead)
            return;

        Debug.Log("dmg?");
        float totalDmg = dmg * _damageRecive[partDamaged];

        hp -= totalDmg;

        if (hp <= 0)
        {
            Death();
            return;
        }

        if (hasKnockback)
        {
            DoKnockback();
        }
        
        if (partDamaged == "Body")
        {
            EventManager.Trigger("AddCoin", 10);
            EventManager.Trigger("OnDamageableHit", 0);
        }
        else if (partDamaged == "Head")
        {
            EventManager.Trigger("AddCoin", 20);
            EventManager.Trigger("OnDamageableHit", 1);
        }
        else if (partDamaged == "WeakPart")
        {
            EventManager.Trigger("AddCoin", 5);
            EventManager.Trigger("OnDamageableHit", 2);
        }
        else
        {
            EventManager.Trigger("OnDamageableHit", 0);
        }
    }

    public abstract void DoKnockback();


    #endregion

    #region Interact
    public void Interact()
    {
        Destroy(gameObject);
    }

    public Transform GetTransform()
    {
        return _bodyCenter;
    }

    public bool CanInteract()
    {
        return isDead;
    }

    public string AnimationToExecute()
    {
        return "vacuum";
    }
    #endregion
}
