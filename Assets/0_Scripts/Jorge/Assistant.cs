using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;
//using UnityFx.Outline;
using Random = UnityEngine.Random;

public enum Interactuables
{
    DOOR,
    ENEMY,
    ELEVATOR,
    WEAPON,
    WEAPONMANAGER,
    COOKINGSTATION,
    INGREDIENT
}

public class Assistant : GenericObject
{
    Action ExtraUpdate = delegate { };

    [SerializeField] private Animator _animator;
    [SerializeField] private Rigidbody _rb;

    private Vector3 _actualDir;

    [SerializeField] private float _followSpeed;
    [SerializeField] private float _interactSpeed;

    [SerializeField] private float _followingDistance;
    [SerializeField] private float _interactDistance;
    [SerializeField] private float _pickupDistance;
    [SerializeField] private float _nodeDistance;
    [SerializeField] private Transform _pickUpPoint;

    private Path nodeList;
    private Action<Path> _successPFRequest;
    private Action _failPFRequest;
    private bool _waitingPF = false;
    private JorgeStates _actualState;
    private JorgeStates _previousState;
    [SerializeField] Transform _previousObjective;

    [SerializeField] float _rotationSpeed;

    [SerializeField] float _enemiesDetectionDistance;

    [SerializeField] float _hidingSpotsDetectionDistance;

    [SerializeField] private float _interactDetectionDistance;
    private IAssistInteract _interactuable;

    bool _isInteracting = false;

    [SerializeField] Transform _vacuumPoint;
    [SerializeField] VaccumControllerShader _vacuumVFX;
    [SerializeField] Material _blackholeMat;
    [SerializeField] float _loadingAmmount;
    [SerializeField] float _loadingSpeed;
    List<Renderer> _actualRenders;

    private Transform _actualObjective;
    private Vector3 _dir;

    private Vector3 _obstacleDir = Vector3.zero;
    private float _obstacleDistance = 2;
    [SerializeField] private float _obstacleSpeed = 2;

    private bool _canMove = true;

    private Vector3[] _dirs => new Vector3[]
    {
        transform.forward,
        transform.forward + transform.right,
        transform.forward + transform.right * -1,
        transform.forward * -1 + transform.right,
        transform.forward * -1 + transform.right * -1,
        transform.forward * -1,
        transform.right,
        transform.right * -1,
        transform.up,
        transform.up * -1,
    };

    [SerializeField] Transform _player;
    public IAssistInteract _holdingItem { get; private set; }

    [SerializeField] private float interactDialogueCount, eatDialogueCount;
    [SerializeField] [Range(0, 100)] private float dialogueChance;
    

    public enum JorgeStates
    {
        FOLLOW,
        PATHFINDING,

        //WAITFORINTERACT,
        INTERACT,
        PICKUP,
        USEIT,
        HIDE
    }

    private EventFSM<JorgeStates> fsm;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
        UpdateManager.instance.AddComponents(new PausableObject() { anim = _animator, rb = _rb });
    }

    public override void OnAwake()
    {
        EventManager.Subscribe("OnAssistantStart", OnAssistantStart);

        EventManager.Subscribe("ChangeMovementState", ChangeCinematicMode);
        GameManager.Instance.Assistant = this;

        _successPFRequest = path =>
        {
            _waitingPF = false;
            nodeList = path;
            _actualObjective = nodeList.GetNextNode().transform;
        };

        _failPFRequest = () =>
        {
            _waitingPF = false;
            ResetGeorge();
        };
    }

    public override void OnStart()
    {
        EventManager.Trigger("SetAssistant", this);
        _player = GameManager.Instance.Player.transform;
        DoFsmSetup();
    }

    void DoFsmSetup()
    {
        #region SETUP

        var follow = new State<JorgeStates>("FOLLOW");
        var pathFinding = new State<JorgeStates>("PATHFINDING");
        //var waitForInteract = new State<JorgeStates>("WAITFORINTERACT");
        var interact = new State<JorgeStates>("INTERACT");
        var pickup = new State<JorgeStates>("PICKUP");
        var useit = new State<JorgeStates>("USEIT");
        var hide = new State<JorgeStates>("HIDE");

        StateConfigurer.Create(follow)
            .SetTransition(JorgeStates.PATHFINDING, pathFinding)
            //.SetTransition(JorgeStates.WAITFORINTERACT, waitForInteract)
            .SetTransition(JorgeStates.INTERACT, interact)
            .SetTransition(JorgeStates.PICKUP, pickup)
            .SetTransition(JorgeStates.USEIT, useit)
            .SetTransition(JorgeStates.HIDE, hide)
            .Done();

        StateConfigurer.Create(pathFinding)
            .SetTransition(JorgeStates.FOLLOW, follow)
            //.SetTransition(JorgeStates.WAITFORINTERACT, waitForInteract)
            .SetTransition(JorgeStates.INTERACT, interact)
            .SetTransition(JorgeStates.PICKUP, pickup)
            .SetTransition(JorgeStates.USEIT, useit)
            .SetTransition(JorgeStates.HIDE, hide)
            .Done();

        // StateConfigurer.Create(waitForInteract)
        //     .SetTransition(JorgeStates.FOLLOW, follow)
        //     .SetTransition(JorgeStates.PATHFINDING, pathFinding)
        //     .SetTransition(JorgeStates.INTERACT, interact)
        //     .SetTransition(JorgeStates.PICKUP, pickup)
        //     .SetTransition(JorgeStates.USEIT, useit)
        //     .Done();

        StateConfigurer.Create(interact)
            .SetTransition(JorgeStates.FOLLOW, follow)
            .SetTransition(JorgeStates.PATHFINDING, pathFinding)
            //.SetTransition(JorgeStates.WAITFORINTERACT, waitForInteract)
            //.SetTransition(JorgeStates.PICKUP, pickup)
            .SetTransition(JorgeStates.HIDE, hide)
            .Done();

        StateConfigurer.Create(pickup)
            .SetTransition(JorgeStates.FOLLOW, follow)
            .SetTransition(JorgeStates.PATHFINDING, pathFinding)
            //.SetTransition(JorgeStates.WAITFORINTERACT, waitForInteract)
            //.SetTransition(JorgeStates.INTERACT, interact)
            .SetTransition(JorgeStates.USEIT, useit)
            .SetTransition(JorgeStates.HIDE, hide)
            .Done();

        StateConfigurer.Create(useit)
            .SetTransition(JorgeStates.FOLLOW, follow)
            .SetTransition(JorgeStates.PATHFINDING, pathFinding)
            //.SetTransition(JorgeStates.WAITFORINTERACT, waitForInteract)
            //.SetTransition(JorgeStates.INTERACT, interact)
            .SetTransition(JorgeStates.PICKUP, pickup)
            .SetTransition(JorgeStates.HIDE, hide)
            .Done();

        StateConfigurer.Create(hide)
            .SetTransition(JorgeStates.FOLLOW, follow)
            .SetTransition(JorgeStates.PATHFINDING, pathFinding)
            //.SetTransition(JorgeStates.WAITFORINTERACT, waitForInteract)
            .SetTransition(JorgeStates.INTERACT, interact)
            .SetTransition(JorgeStates.PICKUP, pickup)
            .SetTransition(JorgeStates.USEIT, useit)
            .Done();

        #endregion

        #region FOLLOW

        follow.OnEnter += x =>
        {
            //Debug.Log("follow");
            _actualState = JorgeStates.FOLLOW;
            _actualObjective = _player;
        };

        follow.OnUpdate += () =>
        {
            if (!MPathfinding.OnSight(transform.position, _player.position))
            {
                SendInputToFSM(JorgeStates.PATHFINDING);
                return;
            }

            if (CheckNearEnemies())
            {
                SendInputToFSM(JorgeStates.HIDE);
                return;
            }

            _dir = Vector3.zero;
            _dir = _player.position - transform.position;
            
            if (Vector3.Angle(_dir, transform.forward) > 0)
            {
                var targetRotation = Quaternion.LookRotation(_dir);
                transform.rotation =
                    Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);
            }

            if (_dir.magnitude > _followingDistance)
            {
                _dir.Normalize();
                _dir *= _followSpeed;
            }
            else _dir = Vector3.zero;

            CheckObstacles();
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
            _waitingPF = true;
            _actualState = JorgeStates.PATHFINDING;
            MPathfinding.instance.RequestPath(transform.position, _previousObjective.position, _successPFRequest,
                _failPFRequest);
        };

        pathFinding.OnUpdate += () =>
        {
            if (_waitingPF) return;

            if (MPathfinding.OnSight(transform.position, _previousObjective.position))
            {
                SendInputToFSM(_previousState);
                return;
            }
            
            _dir = Vector3.zero;
            _dir = _actualObjective.position - transform.position;
            
            if (Vector3.Angle(_dir, transform.forward) > 0)
            {
                var targetRotation = Quaternion.LookRotation(_dir);
                transform.rotation =
                    Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);
            }
            
            _dir.Normalize();
            _dir *= _interactSpeed;

            if (Vector3.Distance(transform.position, _actualObjective.position) < _nodeDistance)
            {
                if (nodeList.PathCount() > 0)
                {
                    _actualObjective = nodeList.GetNextNode().transform;
                }
                else
                {
                    _waitingPF = true;
                    MPathfinding.instance.RequestPath(transform.position, _previousObjective.position,
                        _successPFRequest, _failPFRequest);
                }
            }

            _obstacleDir = Vector3.zero;
            CheckObstacles();
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
            _actualState = JorgeStates.INTERACT;

            _interactuable = _actualObjective.gameObject.GetComponent<IAssistInteract>();
            if (_interactuable == null)
                _interactuable = _actualObjective.gameObject.GetComponentInParent<IAssistInteract>();

            var rand = Random.Range(0f, 100f);
            if (rand <= dialogueChance && _interactuable.GetInteractType() != Interactuables.ENEMY)
            {
                EventManager.Trigger("OnAssistantInteractDialogueTriggered");
            }
        };

        interact.OnUpdate += () =>
        {
            _dir = (_actualObjective.position) - transform.position;

            _dir.Normalize();

            if (Vector3.Angle(_dir, transform.forward) > 0)
            {
                var targetRotation = Quaternion.LookRotation(_dir);
                transform.rotation =
                    Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);
            }

            if (_isInteracting)
            {
                return;
            }

            if (Physics.Raycast(transform.position, _dir, _dir.magnitude * 0.9f, LayerManager.LM_ENEMYSIGHT))
            {
                SendInputToFSM(JorgeStates.PATHFINDING);
            }

            if (Vector3.Distance(transform.position, (_actualObjective.position)) < _interactDistance)
            {
                _actualDir = Vector3.zero;
                _isInteracting = true;
                _obstacleDir = Vector3.zero;

                switch (_interactuable.GetInteractType())
                {
                    case Interactuables.DOOR:
                        _animator.SetBool(_interactuable.AnimationToExecute(), true);
                        StartCoroutine(WaitAction(1, false));
                        break;
                    case Interactuables.ENEMY:
                        _animator.SetBool(_interactuable.AnimationToExecute(), true);
                        StartCoroutine(WaitAction(3, false));


                        var rand = Random.Range(0f, 100f);
                        if (rand <= dialogueChance)
                        {
                            EventManager.Trigger("OnAssistantEatDialogueTriggered");
                        }

                        _actualRenders = _interactuable.GetRenderer();
                        foreach (Renderer render in _actualRenders)
                        {
                            for (int i = 0; i < render.materials.Length; i++)
                            {
                                render.materials[i] = _blackholeMat;
                                render.materials[i].SetVector("_BlackHolePosition",
                                    new Vector4(_vacuumPoint.position.x, _vacuumPoint.position.y,
                                        _vacuumPoint.position.z,
                                        0));
                            }
                            //
                            // render.material = _blackholeMat;
                            // render.material.SetVector("_BlackHolePosition",
                            //     new Vector4(_vacuumPoint.position.x, _vacuumPoint.position.y, _vacuumPoint.position.z,
                            //         0));
                        }

                        LeanTween.value(0, 0.81f, 0.3f).setOnUpdate((float value) => { _vacuumVFX._opacity = value; });
                        
                        GameManager.Instance.Player.Health(15);
                        SoundManager.instance.PlaySound(SoundID.ASSISTANT_HEAL);
                        
                        ExtraUpdate = ChangeBlackHoleVars;
                        //_animator.SetTrigger(_interactuable.AnimationToExecute());
                        break;
                    case Interactuables.ELEVATOR:
                        _animator.SetBool(_interactuable.AnimationToExecute(), true);
                        StartCoroutine(WaitAction(1, false));
                        break;
                    default:
                        break;
                }
            }
            else
            {
                _dir *= _interactSpeed;
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

        pickup.OnEnter += x => { _actualState = JorgeStates.PICKUP; };

        pickup.OnUpdate += () =>
        {
            _dir = Vector3.zero;
            _dir = _actualObjective.position - transform.position;
            
            if (Vector3.Angle(_dir, transform.forward) > 0)
            {
                var targetRotation = Quaternion.LookRotation(_dir);
                transform.rotation =
                    Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);
            }

            if (Physics.Raycast(transform.position, _dir, _dir.magnitude * 0.9f, LayerManager.LM_ENEMYSIGHT))
            {
                SendInputToFSM(JorgeStates.PATHFINDING);
            }

            if (Vector3.Distance(transform.position, _actualObjective.transform.position) < _pickupDistance)
            {
                if (_holdingItem != null && _holdingItem is IPickUp pickUp)
                {
                    pickUp.UnPickUp();
                    _holdingItem = null;
                }
                
                _holdingItem = _actualObjective.gameObject.GetComponent<IAssistInteract>();

                if (_holdingItem == null)
                {
                    SendInputToFSM(JorgeStates.FOLLOW);
                    return;
                }
                
                _actualObjective.transform.rotation = _pickUpPoint.rotation;
                _actualObjective.transform.parent = _pickUpPoint;
                _actualObjective.transform.localPosition = Vector3.zero;

                if (_holdingItem is IPickUp pickUpItem)
                {
                    pickUpItem.Pickup();
                }


                if (_holdingItem.IsAutoUsable())
                {
                    SendInputToFSM(JorgeStates.USEIT);
                }
                else
                {
                    SendInputToFSM(JorgeStates.FOLLOW);
                }
            }

            _dir.Normalize();
            _dir *= _interactSpeed;
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
            if (_holdingItem.IsAutoUsable())
                _actualObjective = _holdingItem.GoesToUsablePoint();
            
            _actualState = JorgeStates.USEIT;
        };

        useit.OnUpdate += () =>
        {
            _dir = Vector3.zero;
            _dir = _actualObjective.position - transform.position;
            
            if (Vector3.Angle(_dir, transform.forward) > 0)
            {
                var targetRotation = Quaternion.LookRotation(_dir);
                transform.rotation =
                    Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);
            }

            if (Physics.Raycast(transform.position, _dir, _dir.magnitude * 0.9f, LayerManager.LM_ENEMYSIGHT))
            {
                SendInputToFSM(JorgeStates.PATHFINDING);
                return;
            }

            if (Vector3.Distance(transform.position, _actualObjective.transform.position) < _pickupDistance)
            {
                var tempItemAction = _actualObjective.GetComponent<IAssistInteract>() ?? _actualObjective.GetComponentInParent<IAssistInteract>();

                if (tempItemAction != null)
                {
                    _holdingItem.GetTransform().transform.parent = null;
                    tempItemAction.Interact(_holdingItem);
                    _holdingItem = null;
                }
                else
                {
                    Destroy(_holdingItem.GetTransform().gameObject);
                    _holdingItem = null;
                }

                SendInputToFSM(JorgeStates.FOLLOW);
            }

            _dir.Normalize();
            _dir *= _interactSpeed;
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
            _actualState = JorgeStates.HIDE;

            Collider[] hidingSpots =
                Physics.OverlapSphere(_player.position, _hidingSpotsDetectionDistance, LayerManager.LM_HIDINGSPOT);

            if (!hidingSpots.Any()) return;

            List<Collider> colliders = hidingSpots
                .OrderBy(x => Vector3.Distance(x.transform.position, transform.position)).ToList();

            _actualObjective = colliders[0].transform;

            var dir = _actualObjective.position - transform.position;
            if (Physics.Raycast(transform.position, dir, dir.magnitude * 0.9f, LayerManager.LM_ALLOBSTACLE))
            {
                SendInputToFSM(JorgeStates.PATHFINDING);
                return;
            }
        };

        hide.OnUpdate += () =>
        {
            if (!CheckNearEnemies()) SendInputToFSM(JorgeStates.FOLLOW);

            _dir = _actualObjective.position - transform.position;

            if (Vector3.Distance(transform.position, _actualObjective.position) < 0.2f)
            {
                _dir = _player.position - transform.position;
            }
            
            if (Vector3.Angle(_dir, transform.forward) > 0)
            {
                var targetRotation = Quaternion.LookRotation(_dir);
                transform.rotation =
                    Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);
            }


            if (Vector3.Distance(transform.position, _actualObjective.position) < 0.2f) _dir = Vector3.zero;
            else
            {
                _dir.Normalize();
                _dir *= _followSpeed;
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

    public override void OnUpdate()
    {
        if (!_canMove) return;
        
        fsm.Update();
        ExtraUpdate();
                
        _actualDir = Vector3.zero;
        _actualDir += _dir + _obstacleDir;

        _rb.velocity = _actualDir;

        if (Input.GetKeyDown(KeyCode.T))
        {
            ResetGeorge();
        }
    }

    public void ResetGeorge()
    {
        _interactuable = null;
        if (_holdingItem != null && _holdingItem.GetTransform() != null)
        {
            _holdingItem.GetTransform().parent = null;
            if (_holdingItem is IPickUp pickUp)
            {
               pickUp.UnPickUp();
            }
        }

        _holdingItem = null;

        _isInteracting = false;

        transform.position = _player.transform.position;
        SendInputToFSM(JorgeStates.FOLLOW);
    }

    private void ChangeCinematicMode(params object[] parameters)
    {
        _canMove = (bool)parameters[0];

        if (!_canMove) _rb.velocity = Vector3.zero;
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
        if (_actualState == JorgeStates.INTERACT
            || _actualState == JorgeStates.USEIT
            || _actualState == JorgeStates.PICKUP
            || (_actualState == JorgeStates.PATHFINDING &&
                (_previousState == JorgeStates.USEIT ||
                 _previousState == JorgeStates.PICKUP ||
                 _previousState == JorgeStates.INTERACT))) return;

        EventManager.Trigger("OnAssistantPing", interactuable);
        SoundManager.instance.PlaySound(SoundID.ASSISTANT_PING);
        _actualObjective = interactuable;
        _previousObjective = interactuable;
        

        SendInputToFSM(goToState);
    }

    public void StartAction()
    {
        _vacuumVFX.gameObject.SetActive(true);
        _vacuumVFX.transform.position = _vacuumPoint.position;
        _vacuumVFX.transform.up = _vacuumPoint.position - _interactuable.GetTransform().position;
    }

    public void FinishAction()
    {
        _animator.ResetTrigger(_interactuable.AnimationToExecute());
        _vacuumVFX.gameObject.SetActive(false);
        _interactuable = null;
        _actualObjective = _player;
        _loadingAmmount = 0;
        ExtraUpdate = delegate { };

        SendInputToFSM(JorgeStates.FOLLOW);
    }

    bool CheckNearEnemies()
    {
        var enemies = Physics.OverlapSphere(_player.position, _enemiesDetectionDistance, LayerManager.LM_ENEMY)
            .Where(x => MPathfinding.OnSight(transform.position, x.transform.position));
        var aliveEnemies = enemies.Select(x => x.GetComponentInParent<Enemy>()).Where(x => !x.isDead).ToList();

        return aliveEnemies.Any();
    }

    private void CheckObstacles()
    {
        _obstacleDir = Vector3.zero;
        RaycastHit hit;

        foreach (var dir in _dirs)
        {
            if (Physics.Raycast(transform.position, dir, out hit, _obstacleDistance, LayerManager.LM_ALLOBSTACLE))
            {
                var negativeDir = (dir * -1) * (Vector3.Distance(transform.position, hit.point) / _obstacleDistance);
                _obstacleDir += negativeDir;
            }
        }

        if (_obstacleDir.magnitude > 1) _obstacleDir.Normalize();
        _obstacleDir *= _obstacleSpeed;
    }

    void ChangeBlackHoleVars()
    {
        _loadingAmmount += _loadingSpeed * Time.deltaTime;

        foreach (Renderer render in _actualRenders)
        {
            //render.material.SetFloat("_Effect", _loadingAmmount);

            for (int i = 0; i < render.materials.Length; i++)
            {
                render.materials[i].SetFloat("_Effect", _loadingAmmount);
            }
        }
    }

    void Respawn()
    {
        transform.position = NodeManager.instance.GetNode(NodeManager.instance.GetClosestNode(_player, true), true)
            .transform.position;
        _interactuable = null;
        SendInputToFSM(JorgeStates.FOLLOW);
    }

    //Temp
    IEnumerator WaitAction(float time, bool isTrigger)
    {
        yield return new WaitForSeconds(time);

        if (isTrigger)
        {
            if (_interactuable != null)
                _animator.SetTrigger(_interactuable.AnimationToExecute());
        }
        else
        {
            if (_interactuable != null)
                _animator.SetBool(_interactuable.AnimationToExecute(), false);
        }


        if (_interactuable != null)
            _interactuable.Interact();

        _interactuable = null;
        _actualObjective = _player;
        _loadingAmmount = 0;
        ExtraUpdate = delegate { };

        if (_vacuumVFX._opacity > 0)
        {
            LeanTween.value(0.81f, 0, 0.3f).setOnUpdate((float value) => { _vacuumVFX._opacity = value; });
        }

        SendInputToFSM(JorgeStates.FOLLOW);
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.white;
        if (_previousObjective)
            Gizmos.DrawLine(transform.position, _previousObjective.position);
    }
}