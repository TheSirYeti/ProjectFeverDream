using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Assistant : MonoBehaviour
{
    [SerializeField] float _speed;
    [SerializeField] float _followingDistance;

    Transform _actualObjective;
    Vector3 _dir;

    Transform _player;
    IAttendance _interactuable;

    void Awake()
    {
        EventManager.Subscribe("OnAssistantStart", OnAssistantStart);
    }

    void Start()
    {
        EventManager.Trigger("SetAssistant", this);
        _actualObjective = _player;
    }

    void Update()
    {
        _dir = _actualObjective.position - transform.position;
        transform.forward = _dir;
        if (Vector3.Distance(transform.position, _actualObjective.position) > _followingDistance)
        {
            transform.position += _dir * _speed * Time.deltaTime;
        }
        else if (_interactuable != null)
        {
            //animacion
            _interactuable.Interact();
            FinishAction();
        }
    }

    public void OnAssistantStart(params object[] parameter)
    {
        _player = (Transform)parameter[0];
        _actualObjective = _player;
    }

    public void SetObjective(IAttendance interactuable)
    {
        _interactuable = interactuable;
        _actualObjective = interactuable.GetTransform();
    }

    public void FinishAction()
    {
        _interactuable = null;
        _actualObjective = _player;
    }
}
