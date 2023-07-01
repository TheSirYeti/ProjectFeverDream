using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using System.Linq;
using UnityEngine;
using Debug = UnityEngine.Debug;

//
// //TODO: Testing, delete later
// [ExecuteAlways]
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

    public Path TestNewGetPath(MNode initialNode, MNode targetNode)
    {
        checker = new List<MNode>();

        actualPath = new Path();
        closeNodes = new HashSet<MNode>();
        openNodes = new PriorityQueue<MNode>();
        _nodePath = new Queue<MNode>();

        _origenNode = initialNode;
        _targetNode = targetNode;

        _actualnode = _origenNode;

        AStar();

        return actualPath;
    }

    public Path GetPath(Vector3 origen, Vector3 target)
    {
        checker = new List<MNode>();

        // Stopwatch timer = new Stopwatch();
        // timer.Start();

        actualPath = new Path();
        closeNodes = new HashSet<MNode>();
        openNodes = new PriorityQueue<MNode>();
        _nodePath = new Queue<MNode>();

        _origenNode = GetClosestNode(origen);
        _targetNode = GetClosestNode(target);

        _actualnode = _origenNode;

        AStar();

        // timer.Stop();
        // long ts = timer.ElapsedMilliseconds;
        // Debug.Log("Termine en: " + ts + " milisegundos");

        //TestCleanUp();

        return actualPath;
    }

    void AStar()
    {
        closeNodes.Add(_actualnode);
        openNodes.Enqueue(new TObj<MNode>() { myObj = _actualnode, myWeight = _actualnode.GetWeight() });
        _actualnode.nodeColor = Color.green;

        var watchdog = 10000;
        Queue<MNode> checkingNodes;

        while (_actualnode != _targetNode && openNodes.Count() > 0 && watchdog > 0)
        {
            watchdog--;

            checkingNodes = new Queue<MNode>();


            for (var i = 0; i < _actualnode.NeighboursCount(); i++)
            {
                var node = _actualnode.GetNeighbor(i);

                if (node == null) 
                {
                    continue;
                }
                
                node.nodeColor = Color.magenta;
                if (closeNodes.Contains(node)) continue;
                
                node.SetWeight(_actualnode.GetWeight() + 1 +
                               Vector3.Distance(node.transform.position, _targetNode.transform.position));

                if (node._previouseNode == null || node._previouseNode.GetWeight() < _actualnode.GetWeight())
                {
                    node._previouseNode = _actualnode;
                }
                
                openNodes.Enqueue(new TObj<MNode>() { myObj = node, myWeight = node.GetWeight() });
                checkingNodes.Enqueue(node);
            }

            if (checkingNodes.Count > 0)
            {
                MNode cheaperNode = checkingNodes.Dequeue();
                var insideWatchdog = 1000;
                while (checkingNodes.Count > 0 && insideWatchdog > 0)
                {
                    insideWatchdog--;
                    if (cheaperNode == _targetNode) break;

                    var actualNode = checkingNodes.Dequeue();

                    if (actualNode.GetWeight() < cheaperNode.GetWeight())
                        cheaperNode = actualNode;
                }

                _actualnode = cheaperNode;
            }
            else if (openNodes.Count() > 0)
            {
                while (openNodes.Count() > 0)
                {
                    var checkNode = openNodes.Dequeue();
                    if (closeNodes.Contains(checkNode))
                    {
                        continue;
                    }

                    _actualnode = openNodes.Dequeue();
                    break;
                }
            }


            closeNodes.Add(_actualnode);

            if (openNodes.Count() <= 0)
            {
                _targetNode = _actualnode;
            }
        }

        ThetaStar();
    }

    private void ThetaStar()
    {
        Stack stack = new Stack();
        _actualnode = _targetNode;
        stack.Push(_actualnode);
        var previouseNode = _actualnode._previouseNode;

        if (previouseNode == null) Debug.Log("no existe");
        int watchdog = 10000;
        while (_actualnode != _origenNode && watchdog > 0)
        {
            watchdog--;

            if (previouseNode._previouseNode && OnSight(_actualnode.transform.position,
                    previouseNode._previouseNode.transform.position))
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

        watchdog = 10000;
        while (stack.Count > 0 && watchdog > 0)
        {
            watchdog--;

            MNode nextNode = stack.Pop() as MNode;
            checker.Add(nextNode);
            actualPath.AddNode(nextNode);
        }
    }

    public MNode GetClosestNode(Vector3 t, bool isForAssistant = false)
    {
        var actualSearchingRange = searchingRange;
        var closestNodes = Physics.OverlapSphere(t, actualSearchingRange, LayerManager.LM_NODE)
            .Where(x =>
            {
                var dir = x.transform.position - t;
                return !Physics.Raycast(t, dir, dir.magnitude * 1, LayerManager.LM_OBSTACLE);
            }).ToArray();

        var watchdog = 10000;
        while (closestNodes.Length <= 0 && watchdog > 0)
        {
            watchdog--;
            if (watchdog <= 0)
            {
                return null;
            }

            actualSearchingRange += searchingRange;
            closestNodes = Physics.OverlapSphere(t, actualSearchingRange, LayerManager.LM_NODE)
                .Where(x =>
                {
                    var dir = x.transform.position - t;
                    return !Physics.Raycast(t, dir, dir.magnitude * 1, LayerManager.LM_OBSTACLE);
                }).ToArray();
        }

        MNode mNode = null;

        float minDistance = Mathf.Infinity;
        for (int i = 0; i < closestNodes.Length; i++)
        {
            float distance = Vector3.Distance(t, closestNodes[i].transform.position);
            if (distance <= minDistance)
            {
                var tempNode = closestNodes[i].gameObject.GetComponent<MNode>();

                if (tempNode == null) continue;

                mNode = tempNode;
                minDistance = distance;
            }
        }

        return mNode;
    }

    bool OnSight(Vector3 from, Vector3 to)
    {
        Vector3 dir = to - from;
        Ray ray = new Ray(from, dir);

        if (Physics.Raycast(ray, dir.magnitude, LayerManager.LM_THETAOBSTACLES))
            return false;

        return true;
    }

    // private void OnDrawGizmos()
    // {
    //     Gizmos.color = Color.yellow;
    //     Gizmos.DrawWireSphere(_tempOrigen.position, searchingRange);
    // }
}