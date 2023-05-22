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

    Vector3 _actualDir;

    [SerializeField] LayerMask _collisionMask;

    [SerializeField] float _followSpeed;
    [SerializeField] float _interactSpeed;

    [SerializeField] float _followingDistance;
    [SerializeField] float _interactDistance;
    [SerializeField] float _pickupDistance;
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
    IAssistInteract _interactuable;
    public IAssistPickUp _holdingItem { get; private set; }

    public enum Interactuables
    {
        DOOR,
        ENEMY,
        WEAPON,
        WEAPONMANAGER
    }

    public enum JorgeStates
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
        var useit = new State<JorgeStates>("USEIT");
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
            .SetTransition(JorgeStates.USEIT, useit)
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
            .SetTransition(JorgeStates.USEIT, useit)
            .SetTransition(JorgeStates.HIDE, hide)
            .Done();

        StateConfigurer.Create(useit)
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
            .SetTransition(JorgeStates.USEIT, useit)
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
            _actualDir = newDir * _followingDistance;


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
                    Respawn();
                    break;
                }
            }

            _dir = (_actualObjective.position) - transform.position;

            Quaternion targetRotation = Quaternion.LookRotation(_dir);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

            _actualDir = _dir.normalized * _interactSpeed;

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
            _previousObjective = null;
        };

        #endregion

        #region INTERACT

        interact.OnEnter += x =>
        {
            Debug.Log("interact");

            _interactuable = _actualObjective.gameObject.GetComponent<IAssistInteract>();
            if (_interactuable == null)
                _interactuable = _actualObjective.gameObject.GetComponentInParent<IAssistInteract>();

            Debug.Log(_interactuable.GetTransform().gameObject.name);
        };

        interact.OnUpdate += () =>
        {
            _dir = (_actualObjective.position) - transform.position;

            _dir.Normalize();

            Quaternion targetRotation = Quaternion.LookRotation(_dir);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

            if (_isInteracting) return;

            RaycastHit hit;
            if (Physics.Raycast(transform.position, _dir, out hit, _dir.magnitude, _collisionMask))
            {
                SendInputToFSM(JorgeStates.PATHFINDING);
            }

            if (Vector3.Distance(transform.position, (_actualObjective.position)) < _interactDistance)
            {
                _actualDir = Vector3.zero;
                _isInteracting = true;

                switch (_interactuable.GetType())
                {
                    case Interactuables.DOOR:
                        _animator.SetTrigger(_interactuable.AnimationToExecute());
                        break;
                    case Interactuables.ENEMY:
                        _actualRenders = _interactuable.GetRenderer();
                        foreach (Renderer render in _actualRenders)
                        {
                            render.material = _blackholeMat;
                            render.material.SetVector("_BlackHolePosition", new Vector4(_vacuumPoint.position.x, _vacuumPoint.position.y, _vacuumPoint.position.z, 0));
                        }
                        ExtraUpdate = ChangeBlackHoleVars;
                        _animator.SetTrigger(_interactuable.AnimationToExecute());
                        break;
                    default:
                        break;
                }
            }
            else
            {
                _actualDir = _dir * _interactSpeed;
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

        pickup.OnEnter += x =>
        {
            Debug.Log("Pick Up");
        };

        pickup.OnUpdate += () =>
        {
            _dir = _actualObjective.position - transform.position;

            Quaternion targetRotation = Quaternion.LookRotation(_dir);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

            if (Physics.Raycast(transform.position, _dir, _dir.magnitude * 0.9f, _collisionMask))
            {
                SendInputToFSM(JorgeStates.PATHFINDING);
            }

            if (Vector3.Distance(transform.position, _actualObjective.transform.position) < _pickupDistance)
            {
                _actualObjective.transform.parent = transform;
                _holdingItem = _actualObjective.gameObject.GetComponent<IAssistPickUp>();
                

                if (_holdingItem.IsAutoUsable())
                {
                    SendInputToFSM(JorgeStates.USEIT);
                }
                else
                {
                    SendInputToFSM(JorgeStates.FOLLOW);
                }
            }

            _actualDir = _dir * _interactSpeed;
        };

        pickup.OnExit += x =>
        {
            _previousObjective = _actualObjective;
            _previousState = JorgeStates.PICKUP;
        };

        #endregion

        #region USEIT

        useit.OnEnter += x =>
        {
            _actualObjective = _holdingItem.GetTarget();
            Debug.Log(_actualObjective.name);
        };

        useit.OnUpdate += () =>
        {
            _dir = _actualObjective.position - transform.position;

            Quaternion targetRotation = Quaternion.LookRotation(_dir);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

            if (Physics.Raycast(transform.position, _dir, _dir.magnitude * 0.9f, _collisionMask))
            {
                SendInputToFSM(JorgeStates.PATHFINDING);
            }

            if (Vector3.Distance(transform.position, _actualObjective.transform.position) < _pickupDistance)
            {
                Debug.Log("a");
                IAssistUsable tempItemAction = _actualObjective.GetComponent<IAssistUsable>();

                if (tempItemAction != null)
                {
                    _holdingItem.GetGameObject().transform.parent = null;
                    tempItemAction.UseItem(_holdingItem);
                }
                else
                {
                    Destroy(_holdingItem.GetGameObject());
                }

                SendInputToFSM(JorgeStates.FOLLOW);
            }

            _actualDir = _dir.normalized * _interactSpeed;
        };

        useit.OnExit += x =>
        {
            _previousObjective = _actualObjective;
            _previousState = JorgeStates.USEIT;
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
                _actualDir = Vector3.zero;
                _dir = _player.position - transform.position;

                Quaternion targetRotation = Quaternion.LookRotation(_dir);
                transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);
            }
            else
            {
                Quaternion targetRotation = Quaternion.LookRotation(_dir);
                transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

                _actualDir = _dir * _followSpeed;
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
        _rb.velocity = _actualDir;
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

    public void SetObjective(Transform interactuable, JorgeStates goToState)
    {
        //if (_interactuable != null) return;

        _actualObjective = interactuable;
        _previousObjective = interactuable;

        SendInputToFSM(goToState);
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

    void Respawn()
    {
        transform.position = NodeManager.instance.GetNode(NodeManager.instance.GetClosestNode(_player, true), true).transform.position;
        _interactuable = null;
        SendInputToFSM(JorgeStates.FOLLOW);
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.white;
        if (_previousObjective)
            Gizmos.DrawLine(transform.position, _previousObjective.position);
    }
}
