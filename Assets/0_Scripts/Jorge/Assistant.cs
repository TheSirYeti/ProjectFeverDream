using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;
//using UnityFx.Outline;
using Random = UnityEngine.Random;

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
    private JorgeStates _actualState;
    private JorgeStates _previousState;
    [SerializeField] Transform _previousObjective;

    [SerializeField] float _rotationSpeed;

    [SerializeField] float _enemiesDetectionDistance;
    [SerializeField] LayerMask _enemiesMask;

    [SerializeField] float _hidingSpotsDetectionDistance;
    [SerializeField] LayerMask _hidingSpotsMask;

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

    public enum Interactuables
    {
        DOOR,
        ENEMY,
        ELEVATOR,
        WEAPON,
        WEAPONMANAGER
    }

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
        UpdateManager._instance.AddObject(this);
        UpdateManager._instance.AddComponents(new PausableObject() { anim = _animator, rb = _rb });
    }

    public override void OnAwake()
    {
        EventManager.Subscribe("OnAssistantStart", OnAssistantStart);

        EventManager.Subscribe("ChangeMovementState", ChangeCinematicMode);
        GameManager.Instance.Assistant = this;
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
            _dir = (_player.position) - transform.position;

            if (Physics.Raycast(transform.position, _dir, _dir.magnitude, LayerManager.LM_ENEMYSIGHT))
            {
                SendInputToFSM(JorgeStates.PATHFINDING);
            }

            Quaternion targetRotation = Quaternion.LookRotation(_dir);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

            Vector3 targetMovement = _player.position + (_dir.normalized * -1 * _followingDistance);

            Vector3 newDir = targetMovement - transform.position;
            _actualDir = newDir * _followingDistance;


            if (CheckNearEnemies()) SendInputToFSM(JorgeStates.HIDE);

            _obstacleDir = Vector3.zero;
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
            _actualState = JorgeStates.PATHFINDING;
            nodeList = MPathfinding._instance.GetPath(transform.position, _previousObjective.position);
            _actualObjective = nodeList.GetNextNode().transform;
        };

        pathFinding.OnUpdate += () =>
        {
            _dir = (_actualObjective.position) - transform.position;

            if (OnSight(_previousObjective.position))
            {
                SendInputToFSM(_previousState);
                return;
            }

            Quaternion targetRotation = Quaternion.LookRotation(_dir);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

            _actualDir = _dir.normalized * _interactSpeed;

            if (Vector3.Distance(transform.position, (_actualObjective.position)) < _nodeDistance)
            {
                Vector3 tempDir = _previousObjective.position - transform.position;
                if (!Physics.Raycast(transform.position, tempDir, tempDir.magnitude, LayerManager.LM_ENEMYSIGHT))
                {
                    SendInputToFSM(_previousState);
                }
                else
                {
                    if (nodeList.PathCount() > 0)
                    {
                        _actualObjective = nodeList.GetNextNode().transform;
                    }
                    else
                    {
                        nodeList = MPathfinding._instance.GetPath(transform.position, _previousObjective.position);
                        _actualObjective = nodeList.GetNextNode().transform;
                    }
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
            if (rand <= dialogueChance && _interactuable.GetType() != Interactuables.ENEMY)
            {
                EventManager.Trigger("OnAssistantInteractDialogueTriggered");
            }
        };

        interact.OnUpdate += () =>
        {
            _dir = (_actualObjective.position) - transform.position;

            _dir.Normalize();

            Quaternion targetRotation = Quaternion.LookRotation(_dir);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

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

                switch (_interactuable.GetType())
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
                            render.material = _blackholeMat;
                            render.material.SetVector("_BlackHolePosition",
                                new Vector4(_vacuumPoint.position.x, _vacuumPoint.position.y, _vacuumPoint.position.z,
                                    0));
                        }

                        LeanTween.value(0, 0.81f, 0.3f).setOnUpdate((float value) => { _vacuumVFX._opacity = value; });

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
            _actualState = JorgeStates.PICKUP;
        };

        pickup.OnUpdate += () =>
        {
            _dir = _actualObjective.position - transform.position;

            Quaternion targetRotation = Quaternion.LookRotation(_dir);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

            if (Physics.Raycast(transform.position, _dir, _dir.magnitude * 0.9f, LayerManager.LM_ENEMYSIGHT))
            {
                SendInputToFSM(JorgeStates.PATHFINDING);
            }

            if (Vector3.Distance(transform.position, _actualObjective.transform.position) < _pickupDistance)
            {
                _actualObjective.transform.rotation = _pickUpPoint.rotation;
                _actualObjective.transform.parent = _pickUpPoint;
                _actualObjective.transform.localPosition = Vector3.zero;
                _holdingItem = _actualObjective.gameObject.GetComponent<IAssistInteract>();

                if (_holdingItem == null)
                {
                    SendInputToFSM(JorgeStates.FOLLOW);
                    return;
                }
                
                //TODO lol
                var weapon = _holdingItem.GetTransform().gameObject.GetComponent<GenericWeapon>();
                if (weapon != null)
                {
                    weapon._isEquiped = true;
                    weapon.ChangeCollisions(false);
                }
                
                Debug.Log(_holdingItem.InteractID());


                if (_holdingItem.isAutoUsable())
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
            _actualObjective = _holdingItem.UsablePoint();
            _actualState = JorgeStates.USEIT;
        };

        useit.OnUpdate += () =>
        {
            _dir = _actualObjective.position - transform.position;

            Quaternion targetRotation = Quaternion.LookRotation(_dir);
            transform.rotation = Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);

            if (Physics.Raycast(transform.position, _dir, _dir.magnitude * 0.9f, LayerManager.LM_ENEMYSIGHT))
            {
                SendInputToFSM(JorgeStates.PATHFINDING);
                return;
            }

            if (Vector3.Distance(transform.position, _actualObjective.transform.position) < _pickupDistance)
            {
                var tempItemAction = _actualObjective.GetComponent<IAssistInteract>();

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
            _actualState = JorgeStates.HIDE;
            
            Collider[] hidingSpots =
                Physics.OverlapSphere(_player.position, _hidingSpotsDetectionDistance, _hidingSpotsMask);

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
                _actualDir = Vector3.zero;
                _dir = _player.position - transform.position;
            }
            else
            {
                _actualDir = _dir * _followSpeed;
            }

            Quaternion targetRotation = Quaternion.LookRotation(_dir);
            transform.rotation =
                Quaternion.Lerp(transform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);
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
        _actualDir += _obstacleDir.normalized * _obstacleSpeed;

        if (Input.GetKeyDown(KeyCode.T))
        {
            transform.position = _player.transform.position;
            ResetGeorge();
            SendInputToFSM(JorgeStates.FOLLOW);
        }
    }

    public void ResetGeorge()
    {
        _interactuable = null;
        if(_holdingItem != null && _holdingItem.GetTransform() != null && _holdingItem.GetTransform().parent != null)
            _holdingItem.GetTransform().parent = null;
        _holdingItem = null;
        _isInteracting = false;
    }

    public override void OnFixedUpdate()
    {
        if (!_canMove) return;

        _rb.velocity = _actualDir;
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
        var enemies = Physics.OverlapSphere(_player.position, _enemiesDetectionDistance, _enemiesMask)
            .Where(x => OnSight(x.transform.position));
        var aliveEnemies = enemies.Select(x => x.GetComponentInParent<Enemy>()).Where(x => !x.isDead).ToList();

        if (!aliveEnemies.Any()) return false;

        return true;
    }

    private void CheckObstacles()
    {
        RaycastHit hit;

        foreach (var dir in _dirs)
        {
            if (Physics.Raycast(transform.position, dir, out hit, _obstacleDistance, LayerManager.LM_ALLOBSTACLE))
            {
                var negativeDir = (dir * -1) * (Vector3.Distance(transform.position, hit.point) / _obstacleDistance);
                _obstacleDir += negativeDir;
            }
        }
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
        transform.position = NodeManager.instance.GetNode(NodeManager.instance.GetClosestNode(_player, true), true)
            .transform.position;
        _interactuable = null;
        SendInputToFSM(JorgeStates.FOLLOW);
    }

    bool OnSight(Vector3 objective)
    {
        var dir = objective - transform.position;
        var ray = new Ray(transform.position, dir.normalized);

        return !Physics.Raycast(ray, dir.magnitude, LayerManager.LM_OBSTACLE);
    }

    //Temp
    IEnumerator WaitAction(float time, bool isTrigger)
    {
        yield return new WaitForSeconds(time);
        
        if (isTrigger)
        {
            if(_interactuable != null)
                _animator.SetTrigger(_interactuable.AnimationToExecute());
        }
        else
        {
            if(_interactuable != null)
                _animator.SetBool(_interactuable.AnimationToExecute(), false);
        }

        
        if(_interactuable != null)
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