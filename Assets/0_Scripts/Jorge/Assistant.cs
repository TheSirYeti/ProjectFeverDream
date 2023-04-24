using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;

public class Assistant : MonoBehaviour
{
    Animator _animator;

    [SerializeField] LayerMask _playerMask;
    [SerializeField] LayerMask _collisionMask;

    [SerializeField] float _followSpeed;
    [SerializeField] float _interactSpeed;
    [SerializeField] float _closeDistanceSpeed;
    [SerializeField] float _closeRadiousDetection;

    [SerializeField] float _followingDistance;
    [SerializeField] float _interactDistance;
    [SerializeField] float _nodeDistance;

    [SerializeField]List<Node> nodeList = new List<Node>();
    JorgeStates _previousState;
    [SerializeField]Transform _previousObjective;

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
        PATHFINDING,
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
        var pathFinding = new State<JorgeStates>("PATHFINDING");
        var interact = new State<JorgeStates>("INTERACT");
        var hide = new State<JorgeStates>("HIDE");

        StateConfigurer.Create(follow)
            .SetTransition(JorgeStates.PATHFINDING, pathFinding)
            .SetTransition(JorgeStates.INTERACT, interact)
            .SetTransition(JorgeStates.HIDE, hide)
            .Done();

        StateConfigurer.Create(pathFinding)
            .SetTransition(JorgeStates.FOLLOW, follow)
            .SetTransition(JorgeStates.INTERACT, interact)
            .SetTransition(JorgeStates.HIDE, hide)
            .Done();

        StateConfigurer.Create(interact)
            .SetTransition(JorgeStates.FOLLOW, follow)
            .SetTransition(JorgeStates.PATHFINDING, pathFinding)
            .SetTransition(JorgeStates.HIDE, hide)
            .Done();

        StateConfigurer.Create(hide)
            .SetTransition(JorgeStates.FOLLOW, follow)
            .SetTransition(JorgeStates.PATHFINDING, pathFinding)
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

            if (Physics.Raycast(transform.position, _dir, _dir.magnitude, _collisionMask))
            {
                SendInputToFSM(JorgeStates.PATHFINDING);
            }

            Quaternion targetRotation = Quaternion.LookRotation(_dir);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

            Vector3 targetMovement;
            Collider[] collisions = Physics.OverlapSphere(transform.position, _closeRadiousDetection, _playerMask);

            if (!collisions.Any())
                targetMovement = _actualObjective.position + (_dir.normalized * -1 * _followingDistance);
            else
                targetMovement = _actualObjective.position + (_dir.normalized * -1 * _closeDistanceSpeed);


            Vector3 newDir = targetMovement - transform.position;
            transform.position += newDir * Time.deltaTime;


            if (CheckNearEnemies()) SendInputToFSM(JorgeStates.HIDE);
        };

        follow.OnExit += x =>
        {
            _previousState = JorgeStates.FOLLOW;
            _previousObjective = _actualObjective;
        };

        #endregion

        #region PATHFINDING

        pathFinding.OnEnter += x =>
        {
            nodeList = PathfindingTable.instance.ConstructPathThetaStar(NodeManager.instance.GetClosestNode(transform, true) + "," + NodeManager.instance.GetClosestNode(_actualObjective.transform, true) + "," + true);
            _actualObjective = nodeList[0].transform;
            _objectiveMultipliyer = Vector3.zero;
        };

        pathFinding.OnUpdate += () =>
        {
            _dir = (_actualObjective.position + _objectiveMultipliyer) - transform.position;

            Quaternion targetRotation = Quaternion.LookRotation(_dir);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

            transform.position += _dir.normalized * _interactSpeed * Time.deltaTime;

            if (Vector3.Distance(transform.position, (_actualObjective.position + _objectiveMultipliyer)) < _nodeDistance)
            {
                Vector3 tempDir = _previousObjective.position - transform.position;
                if (!Physics.Raycast(transform.position, tempDir, tempDir.magnitude, _collisionMask))
                {
                    SendInputToFSM(_previousState);
                }
                else
                {
                    nodeList.RemoveAt(0);

                    if (nodeList.Any())
                    {
                        _actualObjective = nodeList[0].transform;
                    }
                    else
                    {
                        string path = NodeManager.instance.GetClosestNode(transform, true) + "," + NodeManager.instance.GetClosestNode(_previousObjective.transform, true) + "," + true;
                        nodeList = PathfindingTable.instance.ConstructPathThetaStar(path);
                        _actualObjective = nodeList[0].transform;
                    }
                }
            }
        };

        pathFinding.OnExit += x =>
        {
            _actualObjective = _previousObjective;
        };

        #endregion

        #region INTERACT

        interact.OnUpdate += () =>
        {
            _dir = (_actualObjective.position + _objectiveMultipliyer) - transform.position;

            RaycastHit hit;
            if (Physics.Raycast(transform.position, _dir, out hit, _dir.magnitude * 0.9f, _collisionMask))
            {
                SendInputToFSM(JorgeStates.PATHFINDING);
            }

            Quaternion targetRotation = Quaternion.LookRotation(_dir);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

            Vector3 targetMovement;

            targetMovement = (_actualObjective.position) + (_dir.normalized * -1 * (_interactDistance * 0.5f));
            Vector3 newDir = targetMovement - transform.position;
            newDir.Normalize();

            if (Vector3.Distance(transform.position, (_actualObjective.position + _objectiveMultipliyer)) < _interactDistance)
            {
                _animator.SetTrigger(_interactuable.AnimationToExecute());
            }
            else
            {
                transform.position += newDir * _interactSpeed * Time.deltaTime;
            }
        };

        interact.OnExit += x =>
        {
            _previousState = JorgeStates.INTERACT;
            _previousObjective = _actualObjective;
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

            _dir = _actualObjective.position - transform.position;

            if (Physics.Raycast(transform.position, _dir, _dir.magnitude * 0.9f, _collisionMask))
            {
                SendInputToFSM(JorgeStates.PATHFINDING);
            }

            if (Vector3.Distance(transform.position, _actualObjective.position) < 0.1f)
            {
                _dir = _player.position - transform.position;

                Quaternion targetRotation = Quaternion.LookRotation(_dir);
                transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);
            }
            else
            {
                Quaternion targetRotation = Quaternion.LookRotation(_dir);
                transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

                transform.position += _dir * _followSpeed * Time.deltaTime;
            }
        };

        hide.OnExit += x =>
        {
            _previousState = JorgeStates.HIDE;
            _previousObjective = _actualObjective;
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
