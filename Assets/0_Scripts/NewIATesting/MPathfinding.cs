using System.Collections;
using System.Collections.Generic;
using System;
using System.Linq;
using UnityEngine;
using Debug = UnityEngine.Debug;

public class MPathfinding : GenericObject
{
    public static MPathfinding instance;
    private Path _actualPath;
    private MNode _origenNode;
    private MNode _targetNode;
    private MNode _actualNode;
    public float searchingRange;
    
    private HashSet<MNode> _closeNodes = new HashSet<MNode>();
    private PriorityQueue<MNode> _openNodes = new PriorityQueue<MNode>();

    private Action ClearNodes = delegate {  };

    private readonly Queue<Tuple<Vector3, Vector3, Action<Path>, Action>> _requestQueue = new ();

    private void Awake()
    {
        instance = this;
        StartCoroutine(LazyPathFinding());
    }

    private IEnumerator LazyPathFinding()
    {
        while (true)
        {
            if (!_requestQueue.Any())
            {
                yield return null;
                continue;
            }

            var actualRequest = _requestQueue.Dequeue();

            GetPath(actualRequest.Item1, actualRequest.Item2);

            if (_actualPath != null && _actualPath.PathCount() > 0) actualRequest.Item3(_actualPath);
            else actualRequest.Item4();

            yield return null;
        }
    }

    public void RequestPath(Vector3 origen, Vector3 target, Action<Path> successCallBack, Action failCallBack)
    {
        _requestQueue.Enqueue(Tuple.Create(origen, target, successCallBack, failCallBack));
    }

    private void GetPath(Vector3 origen, Vector3 target)
    {
        _actualPath = new Path();
        _closeNodes = new HashSet<MNode>();
        _openNodes = new PriorityQueue<MNode>();

        _origenNode = GetClosestNode(origen);

        if (_origenNode == null) return;
        
        _targetNode = GetClosestNode(target);

        if (_targetNode == null) return;

        _actualNode = _origenNode;

        AStar();
        
        ClearNodes();
        ClearNodes = delegate {  };
    }

    private void AStar()
    {
        if (_actualNode == null)
        {
            Debug.Log("ACA DEBERIA CRASHEAR!");
            return;
        }

        _closeNodes.Add(_actualNode);
        _actualNode.nodeColor = Color.green;

        var watchdog = 10000;

        while (_actualNode != _targetNode && watchdog > 0)
        {
            watchdog--;

            for (var i = 0; i < _actualNode.NeighboursCount(); i++)
            {
                var node = _actualNode.GetNeighbor(i);
                node.nodeColor = Color.magenta;
                if (_closeNodes.Contains(node) || 
                    !OnSight(_actualNode.transform.position, node.transform.position) ||
                    (node.previousNode != null && node.previousNode.Weight < _actualNode.Weight)) continue;

                
                node.previousNode = _actualNode;

                if (_actualNode == null)
                {
                    Debug.Log("a");
                }

                if (node == null)
                {
                    Debug.Log("b");
                }
                
                node.SetWeight(_actualNode.Weight + 1 +
                               Vector3.Distance(node.transform.position, _targetNode.transform.position));

                ClearNodes += node.ResetNode;

                _openNodes.Enqueue(node);
            }

            if (!_openNodes.IsEmpty)
            {
                _actualNode = _openNodes.Dequeue();
            }
            else break;

            _closeNodes.Add(_actualNode);
        }

        ThetaStar();
    }

    private void ThetaStar()
    {
        var stack = new Stack();
        _actualNode = _targetNode;
        stack.Push(_actualNode);
        var previousNode = _actualNode.previousNode;

        if (previousNode == null)
        {
            Debug.Log("no existe");
            _actualPath = null;
            return;
        }
        
        var watchdog = 10000;
        while (_actualNode != _origenNode && watchdog > 0)
        {
            watchdog--;

            if (previousNode.previousNode && OnSight(_actualNode.transform.position,
                    previousNode.previousNode.transform.position))
            {
                previousNode = previousNode.previousNode;
            }
            else
            {
                _actualNode.previousNode = previousNode;
                _actualNode = previousNode;
                stack.Push(_actualNode);
            }
        }

        watchdog = 10000;
        while (stack.Count > 0 && watchdog > 0)
        {
            watchdog--;

            var nextNode = stack.Pop() as MNode;
            _actualPath.AddNode(nextNode);
        }
    }

    private MNode GetClosestNode(Vector3 t, bool isForAssistant = false)
    {
        var actualSearchingRange = searchingRange;
        var closestNodes = Physics.OverlapSphere(t, actualSearchingRange, LayerManager.LM_NODE)
            .Where(x => OnSight(t, x.transform.position)).ToArray();

        var watchdog = 100;
        while (closestNodes.Length <= 0)
        {
            watchdog--;
            if (watchdog <= 0)
            {
                return null;
            }

            actualSearchingRange += searchingRange;
            closestNodes = Physics.OverlapSphere(t, actualSearchingRange, LayerManager.LM_NODE)
                .Where(x => OnSight(t, x.transform.position)).ToArray();
        }

        MNode mNode = null;

        var minDistance = Mathf.Infinity;
        foreach (var node in closestNodes)
        {
            var distance = Vector3.Distance(t, node.transform.position);
            if (distance > minDistance) continue;

            var tempNode = node.gameObject.GetComponent<MNode>();

            if (tempNode == null) continue;

            mNode = tempNode;
            minDistance = distance;
        }

        return mNode;
    }

    public static bool OnSight(Vector3 from, Vector3 to)
    {
        var dir = to - from;
        var ray = new Ray(from, dir);

        if (Physics.Raycast(from, dir, out var hit, dir.magnitude,  LayerManager.LM_ENEMYSIGHT))
        {
            Debug.Log(hit.collider.name);
            return false;
        }
        
        return true;
    }
}