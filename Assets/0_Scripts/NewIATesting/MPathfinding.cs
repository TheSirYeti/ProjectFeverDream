using System;
using System.Collections;
using System.Collections.Generic;
using System.Diagnostics;
using UnityEngine;
using Debug = UnityEngine.Debug;

//TODO: Testing, delete later
[ExecuteInEditMode]
public class MPathfinding : GenericObject
{
    [Header("Testing Vars")] public Transform _tempOrigen;
    public Transform _tempTarget;
    public float searchingRange;

    [Header("Real Vars")] public static MPathfinding _instance;
    private Path actualPath;
    public MNode _origenNode;
    public MNode _targetNode;
    private MNode _actualnode;

    public MNode[] nodes;

    private Queue<MNode> _nodePath = new Queue<MNode>();

    private HashSet<MNode> closeNodes = new HashSet<MNode>();
    private HashSet<MNode> openNodes = new HashSet<MNode>();

    private void Awake()
    {
        //TODO: Add subscribe to updatemanager
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

    public Path GetPath(Vector3 origen, Vector3 target)
    {
        foreach (var node in closeNodes)
        {
            node.ResetNode();
        }

        foreach (var node in openNodes)
        {
            node.ResetNode();
        }

        Debug.Log("Path...");
        Stopwatch timer = new Stopwatch();
        timer.Start();

        actualPath = new Path();
        closeNodes = new HashSet<MNode>();
        openNodes = new HashSet<MNode>();
        _nodePath = new Queue<MNode>();

        Stopwatch closestNode = new Stopwatch();
        closestNode.Start();
        _origenNode = GetClosestNode(origen);
        _targetNode = GetClosestNode(target);
        closestNode.Stop();
        Debug.Log("ClosestNode en " + closestNode.ElapsedMilliseconds);

        _actualnode = _origenNode;

        AStar();

        timer.Stop();
        long ts = timer.ElapsedMilliseconds;
        Debug.Log("Termine en: " + ts + " milisegundos");

        return actualPath;
    }

    void AStar()
    {
        closeNodes.Add(_actualnode);
        _actualnode.nodeColor = Color.green;

        int watchdog = 10000;
        
        Stopwatch whileTimer = new Stopwatch();
        whileTimer.Start();
        while (_actualnode != _targetNode && watchdog > 0)
        {
            watchdog--;
            
            _nodePath.Enqueue(_actualnode);
            List<MNode> checkingNodes = new List<MNode>();

            for (int i = 0; i < _actualnode.NeighboursCount(); i++)
            {
                MNode node = _actualnode.GetNeighbor(i);
                if (closeNodes.Contains(node)) continue;

                node._previouseNode = _actualnode;
                node.SetWeight(_actualnode.GetWeight() + 1 +
                               Vector3.Distance(node.transform.position, _targetNode.transform.position));
                checkingNodes.Add(node);
                openNodes.Add(node);
                node.nodeColor = Color.red;
            }

            if (checkingNodes.Count != 0)
            {
                MNode cheaperNode = checkingNodes[0];
                for (int i = 1; i < checkingNodes.Count; i++)
                {
                    if (checkingNodes[i].GetWeight() < cheaperNode.GetWeight())
                        cheaperNode = checkingNodes[i];
                }

                _actualnode = cheaperNode;
                _actualnode.nodeColor = Color.green;
                closeNodes.Add(_actualnode);
            }
            else
            {
                Debug.Log("Anti while true execute");
                break;
            }
        }

        whileTimer.Stop();
        Debug.Log("while en " + whileTimer.ElapsedMilliseconds);
    }

    void ThetaStar()
    {
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

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.yellow;
        Gizmos.DrawWireSphere(_tempOrigen.position, searchingRange);
    }
}