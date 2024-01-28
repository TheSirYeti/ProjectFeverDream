using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Serialization;

public class TimeLineManager : MonoBehaviour
{
    public static TimeLineManager Instance;

    private float _actualTime = 0;

    private bool _isPaused = false;
    
    private struct EventStruct : IWeighted
    {
        public Queue<Action> Event;
        public Queue<float> times;

        public float Weight => times.Peek();
    }

    private readonly PriorityQueue<EventStruct> _eventQueue = new();

    private void Awake()
    {
        Instance = this;

        StartCoroutine(TimeLine_Coroutine());
    }

    /// <summary>
    ///   <para>Add tuples with an Action for the event and a float for the time when this action will execute.</para>
    /// </summary>
    public void AddEvents(params Tuple<Action, float>[] tuples)
    {
        var actualEvent = new EventStruct()
        {
            Event = new Queue<Action>(tuples.Select(x => x.Item1)),
            times = new Queue<float>(tuples.Select(x => x.Item2 + _actualTime))
        };

        _eventQueue.Enqueue(actualEvent);
    }

    public void ChangePauseState(bool state)
    {
        _isPaused = state;
    }

    private IEnumerator TimeLine_Coroutine()
    {
        while (true)
        {
            if (_isPaused)
            {
                yield return null;
                continue;
            }
            
            yield return new WaitForSeconds(.1f);

            _actualTime += .1f;

            if (_eventQueue.IsEmpty || _eventQueue.Peek().times.Peek() > _actualTime) continue;

            var actualEvent = _eventQueue.Dequeue();
            actualEvent.Event.Dequeue().Invoke();
            actualEvent.times.Dequeue();

            if (actualEvent.Event.Any())
            {
                _eventQueue.Enqueue(actualEvent);
            }
        }
    }
}