using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;

public class Assistant : MonoBehaviour
{
    Animator _animator;

    [SerializeField] LayerMask _playerMask;

    [SerializeField] float _followSpeed;
    [SerializeField] float _interactSpeed;
    [SerializeField] float _closeDistanceSpeed;
    [SerializeField] float _closeRadiousDetection;

    [SerializeField] float _followingDistance;
    [SerializeField] float _interactDistance;

    [SerializeField] float _rotationSpeed;

    [SerializeField] float _enemiesDetectionDistance;
    [SerializeField] LayerMask _enemiesMask;

    [SerializeField] float _hidingSpotsDetectionDistance;
    [SerializeField] LayerMask _hidingSpotsMask;

    [SerializeField] GameObject _vacuumVFX;

    Transform _actualObjective;
    Vector3 _objectiveMultipliyer = Vector3.zero;
    Vector3 _dir;

    Transform _player;
    IAttendance _interactuable;

    enum JorgeStates
    {
        FOLLOW,
        INTERACT,
        HIDE
    }

    private EventFSM<JorgeStates> fsm;


    void Awake()
    {
        EventManager.Subscribe("OnAssistantStart", OnAssistantStart);

        _animator = GetComponent<Animator>();
    }

    void Start()
    {
        EventManager.Trigger("SetAssistant", this);
        DoFsmSetup();
    }

    void DoFsmSetup()
    {
        #region SETUP

        var follow = new State<JorgeStates>("FOLLOW");
        var interact = new State<JorgeStates>("INTERACT");
        var hide = new State<JorgeStates>("HIDE");

        StateConfigurer.Create(follow)
            .SetTransition(JorgeStates.INTERACT, interact)
            .SetTransition(JorgeStates.HIDE, hide)
            .Done();

        StateConfigurer.Create(interact)
            .SetTransition(JorgeStates.FOLLOW, follow)
            .SetTransition(JorgeStates.HIDE, hide)
            .Done();

        StateConfigurer.Create(hide)
            .SetTransition(JorgeStates.FOLLOW, follow)
            .SetTransition(JorgeStates.INTERACT, interact)
            .Done();

        #endregion

        #region FOLLOW

        follow.OnEnter += x =>
        {
            _actualObjective = _player;
            _objectiveMultipliyer = Vector3.zero;
        };

        follow.OnUpdate += () =>
        {
            _dir = (_actualObjective.position + _objectiveMultipliyer) - transform.position;

            Quaternion targetRotation = Quaternion.LookRotation(_dir);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

            Vector3 targetMovement;
            Collider[] collisions = Physics.OverlapSphere(transform.position, _closeRadiousDetection, _playerMask);

            if (!collisions.Any())
                targetMovement = _actualObjective.position + (_dir.normalized * -1 * _followingDistance);
            else
                targetMovement = _actualObjective.position + (_dir.normalized * - 1 * _closeDistanceSpeed);


            Vector3 newDir = targetMovement - transform.position;
            transform.position += newDir * Time.deltaTime;


            if (CheckNearEnemies()) SendInputToFSM(JorgeStates.HIDE);
        };

        #endregion

        #region INTERACT

        interact.OnUpdate += () =>
        {
            _dir = (_actualObjective.position + _objectiveMultipliyer) - transform.position;

            Quaternion targetRotation = Quaternion.LookRotation(_dir);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

            Vector3 targetMovement;

            targetMovement = (_actualObjective.position + _objectiveMultipliyer) + (_dir.normalized * -1 * (_interactDistance * 0.5f));
            Vector3 newDir = targetMovement - transform.position;
            newDir.Normalize();
            transform.position += newDir * _interactSpeed * Time.deltaTime;

            if (Vector3.Distance(transform.position, (_actualObjective.position + _objectiveMultipliyer)) < _interactDistance)
            {
                _animator.SetTrigger(_interactuable.AnimationToExecute());
            }
        };

        #endregion

        #region HIDE

        hide.OnEnter += x =>
        {
            Collider[] hidingSpots = Physics.OverlapSphere(_player.position, _hidingSpotsDetectionDistance, _hidingSpotsMask);

            List<Collider> colliders = hidingSpots.OrderBy(x => Vector3.Distance(x.transform.position, transform.position)).ToList();

            _actualObjective = colliders[0].transform;
        };

        hide.OnUpdate += () =>
        {
            if (!CheckNearEnemies()) SendInputToFSM(JorgeStates.FOLLOW);

            if (Vector3.Distance(transform.position, _actualObjective.position) < 0.1f)
            {
                _dir = _player.position - transform.position;

                Quaternion targetRotation = Quaternion.LookRotation(_dir);
                transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);
            }
            else
            {
                _dir = _actualObjective.position - transform.position;

                Quaternion targetRotation = Quaternion.LookRotation(_dir);
                transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

                transform.position += _dir * _followSpeed * Time.deltaTime;
            }
        };

        #endregion

        fsm = new EventFSM<JorgeStates>(follow);
    }

    private void SendInputToFSM(JorgeStates state)
    {
        fsm.SendInput(state);
    }

    void Update()
    {
        fsm.Update();
    }

    //Implementar un movimiento general cuando tenga mas ganas
    void GoToTarget()
    {

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

        if (_interactuable.AnimationToExecute() == "door")
        {
            _objectiveMultipliyer = Vector3.zero;
        }
        else
        {
            _objectiveMultipliyer = Vector3.up * 2;
        }

        SendInputToFSM(JorgeStates.INTERACT);
    }

    public void StartAction()
    {
        _vacuumVFX.SetActive(true);
        _vacuumVFX.transform.position = transform.position;
        _vacuumVFX.transform.up = transform.position - _interactuable.GetTransform().position;
    }

    public void FinishAction()
    {
        _animator.ResetTrigger(_interactuable.AnimationToExecute());
        _vacuumVFX.SetActive(false);
        _interactuable = null;
        _actualObjective = _player;

        SendInputToFSM(JorgeStates.FOLLOW);
    }

    bool CheckNearEnemies()
    {
        Collider[] enemies = Physics.OverlapSphere(_player.position, _enemiesDetectionDistance, _enemiesMask);
        List<Enemy> aliveEnemies = enemies.Select(x => x.GetComponentInParent<Enemy>()).Where(x => !x.isDead).ToList();

        if (!aliveEnemies.Any()) return false;
        else return true;
    }
}
