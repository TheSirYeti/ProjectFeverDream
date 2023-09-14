using System.Collections;
using System.Collections.Generic;
using System;
using System.Diagnostics;
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

    private Action ClearNodes = delegate { };

    private Coroutine _getPathCoroutine;
    private bool _doingPath = false;
    private Coroutine _aStartCoroutine;
    private bool _doingAStart = false;

    private readonly Queue<Tuple<Vector3, Vector3, Action<Path>, Action>> _requestQueue = new();

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

            _doingPath = true;
            _getPathCoroutine = StartCoroutine(GetPath(actualRequest.Item1, actualRequest.Item2));

            yield return new WaitUntil(() => _doingPath = false);

            if (_actualPath != null && _actualPath.PathCount() > 0) actualRequest.Item3(_actualPath);
            else actualRequest.Item4();

            yield return null;
        }
    }

    public void RequestPath(Vector3 origen, Vector3 target, Action<Path> successCallBack, Action failCallBack)
    {
        _requestQueue.Enqueue(Tuple.Create(origen, target, successCallBack, failCallBack));
    }

    private IEnumerator GetPath(Vector3 origen, Vector3 target)
    {
        _actualPath = new Path();
        _closeNodes = new HashSet<MNode>();
        _openNodes = new PriorityQueue<MNode>();

        _origenNode = GetClosestNode(origen);

        if (_origenNode == null)
        {
            _doingPath = false;
            yield break;
        }

        _targetNode = GetClosestNode(target);

        if (_targetNode == null)
        {
            _doingPath = false;
            yield break;
        }

        _actualNode = _origenNode;

        _doingAStart = true;
        _aStartCoroutine = StartCoroutine(AStar());

        yield return new WaitUntil(() => _doingAStart = false);

        ClearNodes();
        ClearNodes = delegate { };
        _doingPath = false;
    }

    private IEnumerator AStar()
    {
        if (_actualNode == null)
        {
            Debug.Log("ACA DEBERIA CRASHEAR!");
            _doingAStart = false;
            yield break;
        }

        _closeNodes.Add(_actualNode);

        var watchdog = 10000;

        var stopWatch = new Stopwatch();
        stopWatch.Start();

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

                if (_actualNode == null)
                {
                    _doingAStart = false;
                    yield break;
                }

                if (node == null)
                {
                    _doingAStart = false;
                    yield break;
                }

                node.previousNode = _actualNode;

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

            if (stopWatch.ElapsedMilliseconds <= 1) continue;
            
            yield return null;
            stopWatch.Restart();
        }

        ThetaStar();
        _doingAStart = false;
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

        return !Physics.Raycast(from, dir, out var hit, dir.magnitude, LayerManager.LM_ENEMYSIGHT);
    }
}