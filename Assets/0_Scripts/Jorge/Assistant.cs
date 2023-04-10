using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Assistant : MonoBehaviour
{
    [SerializeField] float _speed;
    [SerializeField] float _followingDistance;
    [SerializeField] float _interactDistance;

    [SerializeField] float _rotationSpeed;

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
    }

    void Update()
    {
        _dir = _actualObjective.position - transform.position;

        Quaternion targetRotation = Quaternion.LookRotation(_dir);
        transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

        Vector3 targetMovement;
        if (_interactuable != null)
        {
            targetMovement = _actualObjective.position + (_dir.normalized * -1 * (_interactDistance * 0.5f));
        }
        else
        {
            targetMovement = _actualObjective.position + (_dir.normalized * -1 * _followingDistance);
        }

        Vector3 newDir = targetMovement - transform.position;

        transform.position += newDir * _speed * Time.deltaTime;

        if (_interactuable != null && Vector3.Distance(transform.position, _actualObjective.position) < _interactDistance)
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
