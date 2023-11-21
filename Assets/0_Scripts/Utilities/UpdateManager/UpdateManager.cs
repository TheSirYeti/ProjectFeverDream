using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;

public class UpdateManager : MonoBehaviour, ISceneChanges
{
    public static UpdateManager instance;

    private bool _gamePause = false;

    private List<PausableObject> _pausableObjects = new List<PausableObject>();

    // private List<IOnUpdate> _pausableUpdates = new List<IOnUpdate>();
    // private List<IOnUpdate> _continousUpdates = new List<IOnUpdate>();

    private Action _pausableUpdates = delegate { };
    private Action _continuousUpdates = delegate { };

    private Action _pausableFixedUpdates = delegate { };
    private Action _continuousFixedUpdates = delegate { };

    private Action _pausableLateUpdates = delegate { };
    private Action _continuousLateUpdates = delegate { };

    //private Queue<GenericObject> _removeQueue = new Queue<GenericObject>();

    private PriorityQueue<GenericObject> _awakeQueue = new PriorityQueue<GenericObject>();
    private PriorityQueue<GenericObject> _startQueue = new PriorityQueue<GenericObject>();
    private PriorityQueue<GenericObject> _lateStartQueue = new PriorityQueue<GenericObject>();

    private Coroutine initCoroutine;

    private bool _isLoading => GameManager.Instance.isLoading;

    private void Awake()
    {
        Debug.Log("Update awake");
        if (instance) Destroy(gameObject);
        else instance = this;
    }

    private void Update()
    {
        if (_isLoading) return;

        _continuousUpdates();

        if (_gamePause) return;

        _pausableUpdates();
    }

    private void FixedUpdate()
    {
        if (_isLoading) return;

        _continuousFixedUpdates();

        if (_gamePause) return;

        _pausableFixedUpdates();
    }

    private void LateUpdate()
    {
        if (_isLoading) return;
        _continuousLateUpdates();

        if (_gamePause) return;
        _pausableLateUpdates();
    }

    public void OnSceneLoad()
    {
        initCoroutine = StartCoroutine(StartObject());
    }

    public void OnSceneUnload()
    {
        _pausableObjects = new List<PausableObject>();

        _pausableUpdates = delegate { };
        _continuousUpdates = delegate { };

        _pausableFixedUpdates = delegate { };
        _continuousFixedUpdates = delegate { };

        _pausableLateUpdates = delegate { };
        _continuousLateUpdates = delegate { };

        _gamePause = false;

        if (initCoroutine != null) StopCoroutine(initCoroutine);
    }

    public void AddComponents(PausableObject obj)
    {
        _pausableObjects.Add(obj);
    }

    public void AddObject(GenericObject genericObject)
    {
        _awakeQueue.Enqueue(genericObject);
    }

    public void RemoveObject(GenericObject genericObject)
    {
        IOnUpdate updateObject = genericObject;

        if (genericObject.isPausable)
        {
            _pausableUpdates -= updateObject.OnUpdate;
            _pausableFixedUpdates -= updateObject.OnFixedUpdate;
            _pausableLateUpdates -= updateObject.OnLateUpdate;
        }
        else
        {
            _continuousUpdates -= updateObject.OnUpdate;
            _continuousFixedUpdates -= updateObject.OnFixedUpdate;
            _pausableLateUpdates -= updateObject.OnLateUpdate;
        }
    }

    private IEnumerator StartObject()
    {
        yield return new WaitForFrames(4);
        while (true)
        {
            while (_awakeQueue.IsEmpty)
            {
                yield return null;
            }

            while (!_awakeQueue.IsEmpty)
            {
                GenericObject obj = _awakeQueue.Dequeue();

                obj.OnAwake();

                _startQueue.Enqueue(obj);
            }

            while (!_startQueue.IsEmpty)
            {
                GenericObject obj = _startQueue.Dequeue();

                obj.OnStart();

                _lateStartQueue.Enqueue(obj);
            }

            while (!_lateStartQueue.IsEmpty)
            {
                GenericObject obj = _lateStartQueue.Dequeue();

                obj.OnLateStart();

                if (obj.isPausable)
                {
                    _pausableUpdates += obj.OnUpdate;
                    _pausableFixedUpdates += obj.OnFixedUpdate;
                    _pausableLateUpdates += obj.OnLateUpdate;
                }
                else
                {
                    _continuousUpdates += obj.OnUpdate;
                    _continuousFixedUpdates += obj.OnFixedUpdate;
                    _continuousLateUpdates += obj.OnLateUpdate;
                }
            }
        }
    }

    public void ChangeGameState(bool state)
    {
        _gamePause = state;

        if (_gamePause)
        {
            foreach (var obj in _pausableObjects)
            {
                if (obj.anim)
                    obj.anim.speed = 0;

                if (obj.rb)
                {
                    obj.actualSpeed = obj.rb.velocity;
                    obj.rb.velocity = Vector3.zero;
                }
            }
        }
        else
        {
            foreach (var obj in _pausableObjects)
            {
                if (obj.anim)
                    obj.anim.speed = 1;

                if (obj.rb)
                {
                    obj.rb.velocity = obj.actualSpeed;
                }
            }
        }
    }
}

public class PausableObject
{
    public Animator anim;
    public Rigidbody rb;
    public Vector3 actualSpeed;
}