using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Security;
using UnityEngine;

public abstract class Enemy : GenericObject, ITakeDamage
{
    [Header("-== Base Properties ==-")]
    [SerializeField] protected float hp;
    [SerializeField] protected int enemySet;
    protected float maxHP;
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
    protected bool _canMove = true;
    [SerializeField] protected float speed;
    protected float maxSpeed;
    [SerializeField] private float accelerationValue;

    [Space(20)]
    [Header("-== Pathfinding Properties ==-")] 
    //[SerializeField] protected List<Node> nodePath;
    protected Path nodeList;
    protected bool _waitingPF = false;
    private Action<Path> _successPFRequest = delegate(Path path) {  };
    private Action _failPFRequest = delegate {  };
    protected Action _exitPF = delegate {  };
    Vector3 _actualDir;
    [SerializeField] private float minDistanceToNode;
    [SerializeField] protected bool isPathfinding;
    [SerializeField] protected float pathfindingCooldown, pathfindingRate;
    
    Transform _actualObjective;
    Vector3 _dir;
    [SerializeField] Transform _previousObjective;

    [Space(20)]
    [Header("-== Detection / FoV Properties ==-")]
    [SerializeField] protected float fovViewRadius;
    [SerializeField] protected float fovViewAngle;
    [SerializeField] protected Transform fovTransformPoint;
    [SerializeField] protected LayerMask entityDetectionMask;
    
    [Space(20)]
    [Header("-== Ragdoll Properties ==-")] 
    [SerializeField] protected Rigidbody rb;
    [SerializeField] private bool hasRagdoll;
    protected bool isInRagdollMode = false;
    [SerializeField] protected Rigidbody[] ragdollRigidbodies;
    private Vector3 _hitOrigin;
    [SerializeField] private Rigidbody _centerOfMass;
    private OnDeathKnockBacks _lastKnockback;
    [SerializeField] private float[] _knockbacksForce;
    //Temp
    [SerializeField] private Transform _bodyCenter;

    [Space(20)]
    [Header("-== View Properties ==-")]
    [SerializeField] protected Animator animator;
    [Space(20)] 
    [SerializeField] protected List<Renderer> renderers;
    [Space(20)] 
    [SerializeField] protected Renderer faceRenderer;
    [SerializeField] protected float faceTransitionTime;
    [SerializeField] protected float minTransitionValue = 0f, maxTransitionValue = 10f;
    [SerializeField] private ParticleSystem _hitParticle;
    
    protected Dictionary<string, float> _damageRecive = new Dictionary<string, float>();
    [Space(20)] 
    [Header("-== Hitpoints Properties ==-")]
    [SerializeField] protected float dmg;
    [Space(10)] 
    [SerializeField] protected float weakDmg, bodyDmg, headDmg, generalDmg;

    public bool isDead { get; protected set; } = false;

    [Space(20)] [Header("-== SFX Properties ==-")] 
    [SerializeField] protected List<AudioSource> audioSources;
    protected List<int> audioIDs = new List<int>();

    [SerializeField] protected List<AudioSource> detectSFX;
    protected List<int> audioDetectIDs = new List<int>();
    
    [Space(20)] [Header("-== VFX Properties ==-")]
    [SerializeField] protected List<ParticleSystem> deathShockParticles;


    public abstract void Attack();
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
        UpdateManager.instance.AddComponents(new PausableObject(){anim = animator, rb = rb});
        EventManager.Subscribe("ChangeMovementState", ChangeCinematicMode);

        _successPFRequest = path =>
        {
            nodeList = path;
            _waitingPF = false;
            _actualObjective = nodeList.GetNextNode().transform;
        };

        _failPFRequest = () => 
        { 
            isPathfinding = false;
            _waitingPF = false;
            _exitPF();
        };
    }

    private void ChangeCinematicMode(params object[] parameters)
    {
        _canMove = (bool)parameters[0];
    }

    public void SetEnemySetID(int id)
    {
        enemySet = id;
    }
    
    protected void OnResetScene(params object[] parameters)
    {
        //LeanTween.cancel(gameObject);
    }

    #region RAGDOLLS

    public void DoRagdoll()
    {
        if (!hasRagdoll)
            return;
        
        isInRagdollMode = true;

        foreach (var rigidbody in ragdollRigidbodies)
        {
            if (rigidbody != rb)
            {
                rigidbody.isKinematic = false;
                rigidbody.detectCollisions = true;
            }
        }
        
        //collider.enabled = false;
        rb.isKinematic = true;
        animator.enabled = false;

        var forceDir = transform.position - _hitOrigin;
        // 20k escopeta melee
        // 10-15k baguette grande
        // 5-10k baguette dual
        
        _centerOfMass.AddForce(forceDir.normalized * _knockbacksForce[(int)_lastKnockback]);
    }

    public void StopRagdoll()
    {
        if (!hasRagdoll)
            return;
        
        isInRagdollMode = false;

        foreach (var rigidbody in ragdollRigidbodies)
        {
            if (rigidbody != rb)
            {
                rigidbody.isKinematic = true;
                //rigidbody.detectCollisions = false;
            }
        }
        
        //collider.enabled = true;
        rb.isKinematic = false;
        animator.enabled = true;
    }

    protected IEnumerator FreezeAllRigidbodies()
    {
        yield return new WaitForSeconds(3);
        isInRagdollMode = false;

        foreach (var rigidbody in ragdollRigidbodies)
        {
            if (rigidbody != rb)
            {
                rigidbody.detectCollisions = true;
                rigidbody.isKinematic = true;
            }
        }

        ragdollRigidbodies = new[] { rb };
        //collider.enabled = true;
        rb.isKinematic = true;
        animator.enabled = false;
        yield return null;
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
        transform.forward = new Vector3(transform.forward.x, 0, transform.forward.z);
        
        //transform.LookAt(new Vector3(target.transform.position.x, transform.position.y, target.transform.position.z));
        transform.position += transform.forward * speed * Time.deltaTime;
    }

    protected void DoGenericRunAway()
    {
        Vector3 desired = target.transform.position - transform.position;
        desired = new Vector3(desired.x, 0, desired.z);
        desired.Normalize();
        desired *= -1;

        transform.forward = desired;

        //Vector3 lookAtValue = new Vector3(target.transform.position.x, transform.position.y, target.transform.position.z);
        
        //transform.LookAt(transform.position - (lookAtValue - transform.position));
        transform.position += desired * speed * Time.deltaTime;
    }

    public void DoPathfinding()
    {
        _dir = (_actualObjective.position) - transform.position;
        _dir.y = 0;

        Quaternion targetRotation = Quaternion.LookRotation(_dir);
        transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, speed * Time.deltaTime);

        transform.position += _dir.normalized * speed * Time.deltaTime;

        if (Vector3.Distance(transform.position, (_actualObjective.position)) < minDistanceToNode)
        {
            if (nodeList.PathCount() > 0)
            {
                _actualObjective = nodeList.GetNextNode().transform;
            }
            else
            {
                _waitingPF = true;
                
                var fromPoint = transform.position - Vector3.down;
                var toPoint = target.transform.position;
                toPoint.y = fromPoint.y;
                
                MPathfinding.instance.RequestPath(fromPoint, toPoint,  _successPFRequest, _failPFRequest);
            }
        }
        
        if (InSight(transform.position, target.transform.position))
        {
            //Debug.Log("In sight?");
            isPathfinding = false;
        }
    }
    
    protected bool IsInDistance()
    {
        return Vector3.Distance(target.transform.position, transform.position) <= minChaseDistance;
    }

    #endregion

    #region PATHFINDING

    protected void CalculatePathPreview(bool amEscaping)
    {
        //Debug.Log("QUIERO HACER PF");

        if (amEscaping)
        {
            Collider[] nodeCollisions = Physics.OverlapSphere(transform.position, 20f, LayerManager.LM_NODE);

            if (!nodeCollisions.Any()) return;
            Debug.Log("TENGO QUE ESCAPAR AAAAAAAAAAA");

            int furthestNode = 0;
            float maxDistance = -1f;

            for (int i = 0; i < nodeCollisions.Length; i++)
            {
                var distance = Vector3.Distance(transform.position, nodeCollisions[i].transform.position);
                if (distance > maxDistance && InSight(nodeCollisions[i].transform.position, transform.position))
                {
                    furthestNode = i;
                    maxDistance = distance;
                }
            }
            
            
            
            Debug.Log(furthestNode + " - Node to go to");

            _waitingPF = true;
            
            MPathfinding.instance.RequestPath(transform.position, 
                nodeCollisions[furthestNode].transform.position, _successPFRequest, _failPFRequest);
            
        }
        else
        {               
            var fromPoint = transform.position - Vector3.down;
            var toPoint = target.transform.position;
            toPoint.y = fromPoint.y;
            _waitingPF = true;
            MPathfinding.instance.RequestPath(fromPoint, toPoint, _successPFRequest, _failPFRequest);
        }
        Debug.Log("LLEGO A TERMINAR DE CALCULAR EL PF");
    }
    protected bool InSight(Vector3 start, Vector3 end)
    {
        return MPathfinding.OnSight(start, end);
    }

    protected bool InSight(Vector3 start, Vector3 end, Vector3 offset)
    {
        var fromPoint = start + offset;
        var toPoint = end;
        toPoint.y = fromPoint.y;

        return MPathfinding.OnSight(fromPoint, toPoint);
    }

    #endregion

    #region DETECTION / SIGHT METHODS

    public bool IsInFieldOfView()
    {
        bool isInView = false;
        Collider[] targetsInViewRadius = Physics.OverlapSphere(fovTransformPoint.position, fovViewRadius, entityDetectionMask);

        foreach (var item in targetsInViewRadius)
        {
            Vector3 dirToTarget = (item.transform.position - fovTransformPoint.position);
            
            if (Vector3.Angle(fovTransformPoint.forward, dirToTarget.normalized) < fovViewAngle / 2)
            {
                if (InSight(fovTransformPoint.position, item.transform.position))
                {
                    Debug.DrawLine(fovTransformPoint.position, item.transform.position, Color.red);
                    isInView = true;
                }
                else
                {
                    Debug.DrawLine(fovTransformPoint.position, item.transform.position, Color.green);
                    isInView = false;
                }
            }
        }

        return isInView;
    }

    public abstract void SetDetection();


    #endregion
    
    #region DAMAGE / HEALTH
    
    public abstract void Death();
    
    private void OnTriggerEnter(Collider other)
    {
        if (isDead || !isAttacking) return;
        
        IPlayerLife playerLife = other.GetComponentInParent<IPlayerLife>();

        if (playerLife != null)
        {
            playerLife.GetDamage((int)dmg);
            attackCollider.enabled = false;
        }
    }
    
    public void TakeDamage(string partDamaged, float dmg, Vector3 hitOrigin, OnDeathKnockBacks onDeathKnockback = OnDeathKnockBacks.NOKNOCKBACK, bool hasKnockback = false)
    {
        if (!_damageRecive.ContainsKey(partDamaged) || isInRagdollMode || isDead)
            return;

        _hitOrigin = hitOrigin;
        _lastKnockback = onDeathKnockback;
        
        _hitParticle.Play();

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
            //EventManager.Trigger("AddCoin", 10);
            EventManager.Trigger("OnDamageableHit", 0);
        }
        else if (partDamaged == "Head")
        {
            //EventManager.Trigger("AddCoin", 20);
            EventManager.Trigger("OnDamageableHit", 1);
        }
        else if (partDamaged == "WeakPart")
        {
            //EventManager.Trigger("AddCoin", 5);
            EventManager.Trigger("OnDamageableHit", 2);
        }
        else
        {
            EventManager.Trigger("OnDamageableHit", 0);
        }
    }

    public bool IsAlive()
    {
        return !isDead;
    }

    public abstract void DoKnockback();


    #endregion



    #region FACE VALUES

    public enum FaceID
    {
        IDLE,
        COMBAT,
        DETECT,
        DEAD
    }
    
    public void DoFaceTransition(FaceID faceID)
    {
        StopCoroutine(FaceSwap(faceID));
        StartCoroutine(FaceSwap(faceID));
    }

    IEnumerator FaceSwap(FaceID faceID)
    {
        LeanTween.value(minTransitionValue, maxTransitionValue, faceTransitionTime).setOnUpdate((float value) =>
        {
            faceRenderer.materials[1].SetFloat("_StaticChangeFace", value);
        });
        
        yield return new WaitForSeconds(faceTransitionTime);

        
        faceRenderer.materials[1].SetFloat("_ControlFace", (int)faceID);
        
        
        LeanTween.value(maxTransitionValue, minTransitionValue, faceTransitionTime).setOnUpdate((float value) =>
        {
            faceRenderer.materials[1].SetFloat("_StaticChangeFace", value);
        });
        
        yield return new WaitForSeconds(faceTransitionTime);
    }

    #endregion

    #region GIZMOS

    private void OnDrawGizmos()
    {
        if (fovTransformPoint != null)
        {
            Vector3 lineA = DirFromAngle(fovViewAngle / 2 + fovTransformPoint.eulerAngles.y);
            Vector3 lineB = DirFromAngle(-fovViewAngle / 2 + fovTransformPoint.eulerAngles.y);

            Gizmos.DrawLine(fovTransformPoint.position, fovTransformPoint.position + lineA * fovViewRadius);
            Gizmos.DrawLine(fovTransformPoint.position, fovTransformPoint.position + lineB * fovViewRadius);
        }
    }
    
    Vector3 DirFromAngle(float angle)
    {
        return new Vector3(Mathf.Sin(angle * Mathf.Deg2Rad), 0, Mathf.Cos(angle * Mathf.Deg2Rad));
    }
    #endregion
}
