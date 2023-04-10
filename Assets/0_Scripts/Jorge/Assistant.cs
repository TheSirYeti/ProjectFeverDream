using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Assistant : MonoBehaviour
{
    Animator _animator;

    [SerializeField] float _speed;
    [SerializeField] float _followingDistance;
    [SerializeField] float _interactDistance;

    [SerializeField] float _rotationSpeed;

    [SerializeField] float _enemiesDetectionDistance;
    [SerializeField] LayerMask _enemiesMask;

    Transform _actualObjective;
    Vector3 _dir;

    Transform _player;
    IAttendance _interactuable;

    void Awake()
    {
        EventManager.Subscribe("OnAssistantStart", OnAssistantStart);

        _animator = GetComponent<Animator>();
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
            Vector3 newDir = targetMovement - transform.position;
            newDir.Normalize();
            transform.position += newDir * _speed * Time.deltaTime;
        }
        else
        {
            if (!CheckNearEnemies())
            {
                targetMovement = _actualObjective.position + (_dir.normalized * -1 * _followingDistance);
                Vector3 newDir = targetMovement - transform.position;
                transform.position += newDir * Time.deltaTime;
            }
            else
            {
                targetMovement = _actualObjective.position + _actualObjective.forward * -1 * 2;
                Vector3 newDir = targetMovement - transform.position;

                if (Vector3.Distance(transform.position, targetMovement) < 2)
                    transform.position += newDir * Time.deltaTime * _speed * 2;
                else
                    transform.position += newDir * Time.deltaTime * _speed;
            }
        }


        if (_interactuable != null && Vector3.Distance(transform.position, _actualObjective.position) < _interactDistance)
        {
            _animator.SetTrigger("interact");
        }
    }

    public void Interact()
    {
        _interactuable.Interact();
        FinishAction();
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
        _animator.ResetTrigger("interact");
    }

    bool CheckNearEnemies()
    {
        Collider[] enemies = Physics.OverlapSphere(_player.position, _enemiesDetectionDistance, _enemiesMask);

        if (enemies.Length == 0) return false;
        else return true;
    }
}
