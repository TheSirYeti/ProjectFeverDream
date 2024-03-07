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

    [SerializeField] private int _watchdogValue = 1500;

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

            yield return new WaitUntil(() => _doingPath == false);

            if (_actualPath != null && _actualPath.AnyInPath()) actualRequest.Item3(_actualPath);
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

        yield return new WaitUntil(() => _doingAStart == false);

        ClearNodes();
        ClearNodes = delegate { };
        _doingPath = false;
    }

    private IEnumerator AStar()
    {
        if (_actualNode == null)
        {
            _doingAStart = false;
            yield break;
        }

        //_actualNode.SetWeight(0);
        _closeNodes.Add(_actualNode);

        var watchdog = _watchdogValue;
        var loopsUntilLazy = 300;

        while (!OnSight(_actualNode.transform.position, _targetNode.transform.position) && watchdog > 0)
        {
            watchdog--;
            loopsUntilLazy--;

            if (!_actualNode)
            {
                _doingAStart = false;
                yield break;
            }

            foreach (var node in _actualNode.neighbors.Where(node => !_closeNodes.Contains(node) &&
                                                                     (node.previousNode == null ||
                                                                      !(node.previousNode.Weight <
                                                                        _actualNode.Weight))))
            {
                if (!node)
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
                _actualNode = _openNodes.Dequeue();
            else
            {
                _doingAStart = false;
                yield break;
            }

            _closeNodes.Add(_actualNode);

            if (loopsUntilLazy > 0) continue;

            yield return null;
            loopsUntilLazy = 300;
        }

        if (watchdog <= 0)
        {
            _doingAStart = false;
            yield break;
        }

        _targetNode.previousNode = _actualNode;

        ThetaStar();
        _doingAStart = false;
    }

    private void ThetaStar()
    {
        var stack = new Stack<MNode>();
        stack.Push(_targetNode);
        _actualNode = _targetNode;
        var previousNode = _actualNode.previousNode;

        if (previousNode == null)
        {
            _actualPath = null;
            return;
        }

        var watchdog = _watchdogValue;
        while (!OnSight(_actualNode.transform.position, _origenNode.transform.position)
               && watchdog > 0)
        {
            if (Mathf.Abs(_actualNode.transform.position.y - previousNode.transform.position.y) > .1f)
            {
                _actualNode.previousNode = previousNode;
                _actualNode = previousNode;
                stack.Push(_actualNode);
                continue;
            }

            watchdog--;

            if (previousNode.previousNode &&
                OnSight(_actualNode.transform.position, previousNode.previousNode.transform.position))
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

        while (stack.Count > 0)
        {
            var nextNode = stack.Pop();
            _actualPath.AddNode(nextNode);
        }
    }

    private MNode GetClosestNode(Vector3 t, bool isForAssistant = false)
    {
        var actualSearchingRange = searchingRange;
        var closestNodes = Physics.OverlapSphere(t, actualSearchingRange, LayerManager.LM_NODE)
            .Where(x => OnSight(t, x.transform.position));

        var watchdog = 100;
        while (!closestNodes.Any())
        {
            watchdog--;
            if (watchdog <= 0)
            {
                return null;
            }

            actualSearchingRange += searchingRange;
            closestNodes = Physics.OverlapSphere(t, actualSearchingRange, LayerManager.LM_NODE)
                .Where(x => OnSight(t, x.transform.position));
        }

        return closestNodes.OrderBy(x => Vector3.Distance(t, x.transform.position)).First().GetComponent<MNode>();
    }

    public static bool OnSight(Vector3 from, Vector3 to)
    {
        var dir = to - from;

        return !Physics.Raycast(from, dir, dir.magnitude, LayerManager.LM_ENEMYSIGHT);
    }
}