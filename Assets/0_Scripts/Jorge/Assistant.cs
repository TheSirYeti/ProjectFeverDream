using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;

public class Assistant : MonoBehaviour
{
    Action ExtraUpdate = delegate { };

    Animator _animator;
    public Rigidbody _rb;

    Vector3 actualDir;

    [SerializeField] LayerMask _playerMask;
    [SerializeField] LayerMask _collisionMask;

    [SerializeField] float _followSpeed;
    [SerializeField] float _interactSpeed;
    [SerializeField] float _closeDistanceSpeed;
    [SerializeField] float _closeRadiousDetection;

    [SerializeField] float _followingDistance;
    [SerializeField] float _interactDistance;
    [SerializeField] float _nodeDistance;

    [SerializeField] List<Node> nodeList = new List<Node>();
    JorgeStates _previousState;
    [SerializeField] Transform _previousObjective;

    [SerializeField] float _rotationSpeed;

    [SerializeField] float _enemiesDetectionDistance;
    [SerializeField] LayerMask _enemiesMask;

    [SerializeField] float _hidingSpotsDetectionDistance;
    [SerializeField] LayerMask _hidingSpotsMask;

    bool _isInteracting = false;

    [SerializeField] Transform _vacuumPoint;
    [SerializeField] GameObject _vacuumVFX;
    [SerializeField] Material _blackholeMat;
    [SerializeField] float _loadingAmmount;
    [SerializeField] float _loadingSpeed;
    List<Renderer> _actualRenders;

    Transform _actualObjective;
    Vector3 _dir;

    Transform _player;
    IAttendance _interactuable;

    GenericWeapon _holdingWeapon;
    WeaponManager _weaponManager;

    public enum Interactuables
    {
        DOOR,
        ENEMY,
        WEAPON,
        WEAPONMANAGER
    }

    enum JorgeStates
    {
        FOLLOW,
        PATHFINDING,
        INTERACT,
        PICKUP,
        USEIT,
        HIDE
    }

    private EventFSM<JorgeStates> fsm;


    void Awake()
    {
        EventManager.Subscribe("OnAssistantStart", OnAssistantStart);

        _rb = GetComponent<Rigidbody>();
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
        var pickup = new State<JorgeStates>("PICKUP");
        var useIt = new State<JorgeStates>("USEIT");
        var hide = new State<JorgeStates>("HIDE");

        StateConfigurer.Create(follow)
            .SetTransition(JorgeStates.PATHFINDING, pathFinding)
            .SetTransition(JorgeStates.INTERACT, interact)
            .SetTransition(JorgeStates.PICKUP, pickup)
            .SetTransition(JorgeStates.HIDE, hide)
            .Done();

        StateConfigurer.Create(pathFinding)
            .SetTransition(JorgeStates.FOLLOW, follow)
            .SetTransition(JorgeStates.INTERACT, interact)
            .SetTransition(JorgeStates.PICKUP, pickup)
            .SetTransition(JorgeStates.USEIT, useIt)
            .SetTransition(JorgeStates.HIDE, hide)
            .Done();

        StateConfigurer.Create(interact)
            .SetTransition(JorgeStates.FOLLOW, follow)
            .SetTransition(JorgeStates.PATHFINDING, pathFinding)
            .SetTransition(JorgeStates.PICKUP, pickup)
            .SetTransition(JorgeStates.HIDE, hide)
            .Done();

        StateConfigurer.Create(pickup)
            .SetTransition(JorgeStates.FOLLOW, follow)
            .SetTransition(JorgeStates.PATHFINDING, pathFinding)
            .SetTransition(JorgeStates.INTERACT, interact)
            .SetTransition(JorgeStates.USEIT, useIt)
            .SetTransition(JorgeStates.HIDE, hide)
            .Done();

        StateConfigurer.Create(useIt)
            .SetTransition(JorgeStates.FOLLOW, follow)
            .SetTransition(JorgeStates.PATHFINDING, pathFinding)
            .SetTransition(JorgeStates.INTERACT, interact)
            .SetTransition(JorgeStates.PICKUP, pickup)
            .SetTransition(JorgeStates.HIDE, hide)
            .Done();

        StateConfigurer.Create(hide)
            .SetTransition(JorgeStates.FOLLOW, follow)
            .SetTransition(JorgeStates.PATHFINDING, pathFinding)
            .SetTransition(JorgeStates.INTERACT, interact)
            .SetTransition(JorgeStates.PICKUP, pickup)
            .SetTransition(JorgeStates.USEIT, useIt)
            .Done();

        #endregion

        #region FOLLOW

        follow.OnEnter += x =>
        {
            Debug.Log("follow");
            _actualObjective = _player;
        };

        follow.OnUpdate += () =>
        {
            _dir = (_player.position) - transform.position;

            if (Physics.Raycast(transform.position, _dir, _dir.magnitude, _collisionMask))
            {
                SendInputToFSM(JorgeStates.PATHFINDING);
            }

            Quaternion targetRotation = Quaternion.LookRotation(_dir);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

            Vector3 targetMovement = _player.position + (_dir.normalized * -1 * _followingDistance);
            //Collider[] collisions = Physics.OverlapSphere(transform.position, _closeRadiousDetection, _playerMask);

            //if (!collisions.Any())
            //    targetMovement = _actualObjective.position + (_dir.normalized * -1 * _followingDistance);
            //else
            //    targetMovement = _actualObjective.position + (_dir.normalized * -1 * _closeDistanceSpeed);


            Vector3 newDir = targetMovement - transform.position;
            actualDir = newDir * _followingDistance;


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
            Debug.Log("path");
            nodeList = PathfindingTable.instance.ConstructPathThetaStar(NodeManager.instance.GetClosestNode(transform, true) + "," + NodeManager.instance.GetClosestNode(_actualObjective.transform, true) + "," + true);
            _actualObjective = nodeList[0].transform;
        };

        pathFinding.OnUpdate += () =>
        {
            int i = 0;
            while (!nodeList.Any())
            {
                nodeList = PathfindingTable.instance.ConstructPathThetaStar(NodeManager.instance.GetClosestNode(transform, true) + "," + NodeManager.instance.GetClosestNode(_actualObjective.transform, true) + "," + true);
                i++;

                if (i > 10)
                {
                    transform.position = _player.position - transform.forward * 2;
                    _interactuable = null;
                    SendInputToFSM(JorgeStates.FOLLOW);
                    break;
                }
            }

            _dir = (_actualObjective.position) - transform.position;

            if (_dir == Vector3.zero)
            {
                transform.position = _player.position - transform.forward * 2;
                _interactuable = null;
                SendInputToFSM(JorgeStates.FOLLOW);
            }

            Quaternion targetRotation = Quaternion.LookRotation(_dir);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

            actualDir = _dir.normalized * _interactSpeed;

            if (Vector3.Distance(transform.position, (_actualObjective.position)) < _nodeDistance)
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

        interact.OnEnter += x =>
        {
            Debug.Log("interact");
        };

        interact.OnUpdate += () =>
        {
            if (_isInteracting) return;

            _dir = (_actualObjective.position) - transform.position;

            RaycastHit hit;
            if (Physics.Raycast(transform.position, _dir, out hit, _dir.magnitude, _collisionMask))
            {
                SendInputToFSM(JorgeStates.PATHFINDING);
            }

            _dir.Normalize();

            Quaternion targetRotation = Quaternion.LookRotation(_dir);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

            if (Vector3.Distance(transform.position, (_actualObjective.position)) < _interactDistance)
            {
                actualDir = Vector3.zero;
                _isInteracting = true;

                switch (_interactuable.GetType())
                {
                    case Interactuables.DOOR:
                        _animator.SetTrigger(_interactuable.AnimationToExecute());
                        break;
                    case Interactuables.ENEMY:
                        foreach (Renderer render in _actualRenders)
                        {
                            render.material = _blackholeMat;
                            render.material.SetVector("_BlackHolePosition", new Vector4(_vacuumPoint.position.x, _vacuumPoint.position.y, _vacuumPoint.position.z, 0));
                        }
                        ExtraUpdate = ChangeBlackHoleVars;
                        _animator.SetTrigger(_interactuable.AnimationToExecute());
                        break;
                    //case Interactuables.WEAPON:
                    //    _interactuable.GetTransform().parent = transform;
                    //    _interactuable.Interact();
                    //    //_holdingWeapon = _interactuable;
                    //    //_interactuable = _weaponManager;
                    //    _actualObjective = _interactuable.GetTransform();
                    //    _isInteracting = false;
                    //    break;
                    //case Interactuables.WEAPONMANAGER:
                    //    //_interactuable.Interact(_holdingWeapon.GetTransform().gameObject);
                    //    _interactuable = null;
                    //    SendInputToFSM(JorgeStates.FOLLOW);
                    //    break;
                    default:
                        break;
                }
            }
            else
            {
                actualDir = _dir * _interactSpeed;
            }
        };

        interact.OnExit += x =>
        {
            _previousState = JorgeStates.INTERACT;
            _previousObjective = _actualObjective;
            _isInteracting = false;
        };

        #endregion

        #region PICKUP

        pickup.OnUpdate += () =>
        {
            Debug.Log("a");
        };

        #endregion

        #region GIVEIT

        useIt.OnUpdate += () =>
        {
            Debug.Log("b");
        };

        #endregion

        #region HIDE

        hide.OnEnter += x =>
        {
            Debug.Log("hide");

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
                actualDir = Vector3.zero;
                _dir = _player.position - transform.position;

                Quaternion targetRotation = Quaternion.LookRotation(_dir);
                transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);
            }
            else
            {
                Quaternion targetRotation = Quaternion.LookRotation(_dir);
                transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

                actualDir = _dir * _followSpeed;
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
        //Debug.Log(fsm.Current.Name);
        fsm.Update();
        ExtraUpdate();
    }

    private void FixedUpdate()
    {
        _rb.velocity = actualDir;
    }

    public void Interact()
    {
        _interactuable.Interact();
        FinishAction();
    }

    public void OnAssistantStart(params object[] parameter)
    {
        _player = (Transform)parameter[0];
        //_weaponManager = (IAttendance)parameter[1];
        _actualObjective = _player;
    }

    public void SetObjective(IAttendance interactuable)
    {
        //if (_interactuable != null) return;

        _interactuable = interactuable;

        _actualObjective = interactuable.GetInteractPoint();
        _previousObjective = interactuable.GetTransform();

        if (_interactuable.GetType() == Interactuables.ENEMY)
            _actualRenders = _interactuable.GetRenderer();

        SendInputToFSM(JorgeStates.INTERACT);
    }

    public void StartAction()
    {
        _vacuumVFX.SetActive(true);
        _vacuumVFX.transform.position = _vacuumPoint.position;
        _vacuumVFX.transform.up = _vacuumPoint.position - _interactuable.GetTransform().position;
    }

    public void FinishAction()
    {
        _animator.ResetTrigger(_interactuable.AnimationToExecute());
        _vacuumVFX.SetActive(false);
        _interactuable = null;
        _actualObjective = _player;
        _loadingAmmount = 0;
        ExtraUpdate = delegate { };

        SendInputToFSM(JorgeStates.FOLLOW);
    }

    bool CheckNearEnemies()
    {
        Collider[] enemies = Physics.OverlapSphere(_player.position, _enemiesDetectionDistance, _enemiesMask);
        List<Enemy> aliveEnemies = enemies.Select(x => x.GetComponentInParent<Enemy>()).Where(x => !x.isDead).ToList();

        if (!aliveEnemies.Any()) return false;
        else return true;
    }

    void ChangeBlackHoleVars()
    {
        _loadingAmmount += _loadingSpeed * Time.deltaTime;

        foreach (Renderer render in _actualRenders)
        {
            render.material.SetFloat("_Effect", _loadingAmmount);
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.white;
        if (_previousObjective)
            Gizmos.DrawLine(transform.position, _previousObjective.position);
    }
}
