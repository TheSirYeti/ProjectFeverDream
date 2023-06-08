using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;
using Debug = UnityEngine.Debug;

//TODO: Testing, delete later
//[ExecuteInEditMode]
public class MPathfinding : GenericObject
{
    [Header("Testing Vars")] public Transform _tempOrigen;
    public Transform _tempTarget;

    [Header("Real Vars")] public static MPathfinding _instance;
    private Path actualPath;
    private MNode _origenNode;
    private MNode _targetNode;
    private MNode _actualnode;
    public float searchingRange;

    public MNode[] nodes;

    private Queue<MNode> _nodePath = new Queue<MNode>();

    private HashSet<MNode> closeNodes = new HashSet<MNode>();
    private PriorityQueue<MNode> openNodes = new PriorityQueue<MNode>();

    public List<MNode> checker = new List<MNode>();

    private void Awake()
    {
        _instance = this;
    }

    public void ClearNodes()
    {
        Debug.Log("limpiando...");
        foreach (var node in nodes)
        {
            node.ResetNode();
        }
    
        Debug.Log("termine");
    }

    public void TestFunc()
    {
        GetPath(_tempOrigen.position, _tempTarget.position);
    }

    void TestCleanUp()
    {
        foreach (var node in nodes)
        {
            node.ResetNode();
        }
    
        for (int i = 0; i < checker.Count; i++)
        {
            checker[i].nodeColor = Color.green;
            if (i != 0)
                checker[i]._previouseNode = checker[i - 1];
        }
    }

    public Path GetPath(Vector3 origen, Vector3 target)
    {
        checker = new List<MNode>();

        Debug.Log("Path...");
        Stopwatch timer = new Stopwatch();
        timer.Start();

        actualPath = new Path();
        closeNodes = new HashSet<MNode>();
        openNodes = new PriorityQueue<MNode>();
        _nodePath = new Queue<MNode>();
        
        _origenNode = GetClosestNode(origen);
        _targetNode = GetClosestNode(target);

        _actualnode = _origenNode;

        AStar();

        timer.Stop();
        long ts = timer.ElapsedMilliseconds;
        Debug.Log("Termine en: " + ts + " milisegundos");

        //TestCleanUp();

        return actualPath;
    }

    void AStar()
    {
        closeNodes.Add(_actualnode);
        _actualnode.nodeColor = Color.green;

        int watchdog = 10000;
        Queue<MNode> checkingNodes;

        while (_actualnode != _targetNode && watchdog > 0)
        {
            watchdog--;
     
            checkingNodes = new Queue<MNode>();


            for (int i = 0; i < _actualnode.NeighboursCount(); i++)
            {
                MNode node = _actualnode.GetNeighbor(i);
                node.nodeColor = Color.magenta;
                if (closeNodes.Contains(node)) continue;

                node._previouseNode = _actualnode;
                node.SetWeight(_actualnode.GetWeight() + 1 +
                               Vector3.Distance(node.transform.position, _targetNode.transform.position));

                openNodes.Enqueue(node, node.GetWeight());
                checkingNodes.Enqueue(node);
            }

            if (checkingNodes.Count > 0)
            {
                MNode cheaperNode = checkingNodes.Dequeue();
                while (checkingNodes.Count > 0)
                {
                    if(cheaperNode == _targetNode) break;
                    
                    var actualNode = checkingNodes.Dequeue();
                
                    if (actualNode.GetWeight() < cheaperNode.GetWeight())
                        cheaperNode = actualNode;
                
                
                }
                _actualnode = cheaperNode;
            }
            else
            {
                _actualnode = openNodes.Dequeue();
            }
            
            
            closeNodes.Add(_actualnode);
            
            if(_actualnode == _targetNode) Debug.Log("llegue");
        }
        
        ThetaStar();
    }

    private void ThetaStar()
    {
        Stack stack = new Stack();
        _actualnode = _targetNode;
        stack.Push(_actualnode);
        var previouseNode = _actualnode._previouseNode;
        
        if(previouseNode == null) Debug.Log("no existe");
        
        while (_actualnode != _origenNode)
        {
            if (previouseNode._previouseNode && OnSight(_actualnode.transform.position, previouseNode._previouseNode.transform.position))
            {
                previouseNode = previouseNode._previouseNode;
            }
            else
            {
                _actualnode._previouseNode = previouseNode;
                _actualnode = previouseNode;
                stack.Push(_actualnode);
            }
        }


        while (stack.Count > 0)
        {
            checker.Add(stack.Pop() as MNode);
        }
    }

    public MNode GetClosestNode(Vector3 t, bool isForAssistant = false)
    {
        float actualSearchingRange = searchingRange;
        Collider[] _closestNodes = Physics.OverlapSphere(t, searchingRange, LayerManager.LM_NODE);

        while (_closestNodes.Length <= 0)
        {
            actualSearchingRange += searchingRange;
            _closestNodes = Physics.OverlapSphere(t, actualSearchingRange, LayerManager.LM_NODE);
        }
        
        GameObject node = null;

        float minDistance = Mathf.Infinity;
        for (int i = 0; i < _closestNodes.Length; i++)
        {
            float distance = Vector3.Distance(t, _closestNodes[i].transform.position);
            Vector3 dirToTarget = _closestNodes[i].transform.position - t;
            if (distance <= minDistance &&
                !Physics.Raycast(t, dirToTarget, dirToTarget.magnitude, LayerManager.LM_WALL))
            {
                node = _closestNodes[i].gameObject;
                minDistance = distance;
            }
        }

        return node.GetComponent<MNode>();
    }

    bool OnSight(Vector3 from, Vector3 to)
    {
        Vector3 dir = to - from;
        Ray ray = new Ray(from, dir);

        if (Physics.Raycast(ray, dir.magnitude, LayerManager.LM_WALL))
            return false;

        return true;
    }

    // private void OnDrawGizmos()
    // {
    //     Gizmos.color = Color.yellow;
    //     Gizmos.DrawWireSphere(_tempOrigen.position, searchingRange);
    // }
}