using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;

public class UpdateManager : MonoBehaviour, ISceneChanges
{
    public static UpdateManager _instance;

    private bool _gamePause = false;

    private List<GenericObject> _allObjects = new List<GenericObject>();

    private List<IOnUpdate> _pausableUpdates = new List<IOnUpdate>();
    private List<IOnUpdate> _continousUpdates = new List<IOnUpdate>();

    private Queue<GenericObject> _removeQueue = new Queue<GenericObject>();

    private PriorityQueue<GenericObject> _awakeQueue = new PriorityQueue<GenericObject>();
    private PriorityQueue<GenericObject> _startQueue = new PriorityQueue<GenericObject>();
    private PriorityQueue<GenericObject> _lateStartQueue = new PriorityQueue<GenericObject>();

    private Coroutine initCoroutine;

    private bool _isLoading => GameManager.Instance.isLoading;

    private void Awake()
    {
        if (_instance) Destroy(gameObject);

        _instance = this;
    }

    private void Update()
    {
        if (_isLoading) return;

        if (_continousUpdates.Any())
        {
            foreach (var update in _continousUpdates)
            {
                update.OnUpdate();
            }
        }

        if (_gamePause) return;

        if (_pausableUpdates.Any())
        {
            foreach (var update in _pausableUpdates)
            {
                update.OnUpdate();
            }
        }
    }

    private void FixedUpdate()
    {
        if (_isLoading) return;

        if (_continousUpdates.Any())
        {
            foreach (var update in _continousUpdates)
            {
                update.OnFixedUpdate();
            }
        }

        if (_gamePause) return;

        if (_pausableUpdates.Any())
        {
            foreach (var update in _pausableUpdates)
            {
                update.OnFixedUpdate();
            }
        }
    }

    private void LateUpdate()
    {
        while (_removeQueue.Count > 0)
        {
            GenericObject obj = _removeQueue.Dequeue();
            
            _allObjects.Remove(obj);

            if (obj.isPausable)
                _pausableUpdates.Remove(obj);
            else
                _continousUpdates.Remove(obj);
        }
    }

    public void OnSceneLoad()
    {
        initCoroutine = StartCoroutine(StartObject());
    }

    public void OnSceneUnload()
    {
        _allObjects = new List<GenericObject>();
        _pausableUpdates = new List<IOnUpdate>();
        _continousUpdates = new List<IOnUpdate>();
        _removeQueue = new Queue<GenericObject>();
        _gamePause = false;

        if (initCoroutine != null) StopCoroutine(initCoroutine);
    }

    public void AddObject(GenericObject genericObject)
    {
        _awakeQueue.Enqueue(genericObject, genericObject.priority);
    }

    public void RemoveObject(GenericObject genericObject)
    {
        _removeQueue.Enqueue(genericObject);
    }

    private IEnumerator StartObject()
    {
        yield return new WaitForFrames(4);
        while (true)
        {
            while (_awakeQueue.Count() < 1)
            {
                yield return null;
            }

            while (_awakeQueue.Count() > 0)
            {
                GenericObject obj = _awakeQueue.Dequeue();

                obj.OnAwake();

                _startQueue.Enqueue(obj, obj.priority);
            }

            while (_startQueue.Count() > 0)
            {
                GenericObject obj = _startQueue.Dequeue();

                obj.OnStart();

                _lateStartQueue.Enqueue(obj, obj.priority);
            }

            while (_lateStartQueue.Count() > 0)
            {
                GenericObject obj = _lateStartQueue.Dequeue();

                obj.OnLateStart();

                _allObjects.Add(obj);

                if (obj.isPausable)
                    _pausableUpdates = _allObjects.Where(x => x.isPausable).Select(x => x as IOnUpdate).ToList();
                else
                    _continousUpdates = _allObjects.Where(x => !x.isPausable).Select(x => x as IOnUpdate).ToList();
            }
        }
    }

    public void ChangeGameState(bool state)
    {
        _gamePause = state;
    }
}