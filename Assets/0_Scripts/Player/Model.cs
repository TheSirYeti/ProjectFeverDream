using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;

public class Model : GenericObject, IPlayerLife
{
    //Class Reference
    PhysicsSystem _physics;
    Controller _controller;
    View _view;
    [HideInInspector] public WeaponManager weaponManager { get; private set; }
    CameraController _cameraController;
    Assistant _assistant;

    //Component Reference
    Rigidbody _rb;
    Camera _camera;

    [Header("-== Life Properties ==-")] [SerializeField]
    int _maxLife;

    int _life;
    bool _canGetDmg = true;
    float dmgCooldown = 0.5f;
    float currentDmgCooldown = -1f;

    [Space(20)] [Header("-== Physics Properties ==-")] [SerializeField]
    float _gravity = -10f;

    [Space(20)] [Header("-== Movement Properties ==-")]
    float _actualSpeed;

    [SerializeField] float _walkingSpeed;
    [SerializeField] float _runningSpeed;
    [SerializeField] float _slideSpeed;
    [SerializeField] float _crunchSpeed;
    [SerializeField] float _slideDuration;
    Action crouchChecker = delegate { };

    [Space(20)] [Header("-== Jump Properties ==-")] [SerializeField]
    float _jumpDuration;

    [SerializeField] float _jumpForce;
    [SerializeField] float _walljumpDuration;
    [SerializeField] float _walljumpForce;
    [SerializeField] float _jumpDesacceleration;
    [SerializeField] float _wallJumpDesacceleration;
    [SerializeField] float _coyoteTime;
    [SerializeField] LayerMask _floorMask;
    [SerializeField] LayerMask _wallMask;

    Action floorChecker = delegate { };
    Coroutine _coyoteTimeCoroutine;

    // Movement Bools
    public bool isCrouch { get; private set; } = false;
    public bool isRunning { get; private set; } = false;
    public bool isSlide { get; private set; } = false;

    int _jumpCounter = 0;
    bool _canJump = false;
    bool _isOnFloor = false;

    // Coroutines
    Coroutine _slideCoroutine;
    Coroutine _jumpCoroutine;
    Coroutine _walljumpCoroutine;

    // Dir Vector
    Vector3 _dir = Vector3.zero;

    // Colliders
    List<GameObject> _posibleColliders = new List<GameObject>();
    GameObject _actualCollider;

    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    public override void OnAwake()
    {
        GameManager.Instance.Player = this;
        _view = FindObjectOfType<View>();
        weaponManager = FindObjectOfType<WeaponManager>();

        _camera = Camera.main;

        weaponManager.SetRef(this, _camera.transform, _view);
        _cameraController = GetComponent<CameraController>();
        _controller = new Controller(this, _cameraController, weaponManager);
        _rb = GetComponent<Rigidbody>();
        _physics = new PhysicsSystem(_rb);

        Transform collidersParent = transform.Find("Colliders");

        foreach (Transform child in collidersParent)
        {
            _posibleColliders.Add(child.gameObject);
            child.gameObject.SetActive(false);
        }

        _actualCollider = _posibleColliders[0];
        _actualCollider.SetActive(true);

        _actualSpeed = _walkingSpeed;
        _life = _maxLife;

        _physics.ApplyAcceleration("gravity", Vector3.down, _gravity, Mathf.Infinity);

        EventManager.Subscribe("SetAssistant", SetAssistant);

        floorChecker = CheckOffFloor;
    }

    public override void OnStart()
    {
        EventManager.Trigger("OnAssistantStart", _camera.transform, weaponManager.GetComponent<IAssistInteract>());
        EventManager.Trigger("OnViewStart", this, weaponManager);
    }

    public override void OnUpdate()
    {
        _controller.onUpdate();

        floorChecker();
        crouchChecker();

        CheckDmg();

        currentDmgCooldown -= Time.deltaTime;

        if (_isOnFloor && _physics.HasGravity()) _physics.RemoveAcceleration("gravity");
    }

    public override void OnFixedUpdate()
    {
        _physics.PhysicsFixedUpdate();
    }

    public void Move(float hAxie, float vAxie)
    {
        if (_isOnFloor && (hAxie != 0 || vAxie != 0))
        {
            EventManager.Trigger("CameraBobbing", true);

            if (!isCrouch)
            {
                if (isRunning)
                {
                    _view.PlayLoopingSound(SoundID.RUN);
                    SoundManager.instance.StopSoundByID("WALK");
                }
                else
                {
                    _view.PlayLoopingSound(SoundID.WALK);
                    SoundManager.instance.StopSoundByID("RUN");
                }
            }
            else
            {
                SoundManager.instance.StopSoundByID("RUN");
                SoundManager.instance.StopSoundByID("WALK");
            }
        }
        else
        {
            EventManager.Trigger("CameraBobbing", false);
            SoundManager.instance.StopSoundByID("RUN");
            SoundManager.instance.StopSoundByID("WALK");
        }

        _dir = (transform.right * hAxie + transform.forward * vAxie);

        _dir = AlignDir();

        if (_dir.magnitude > 1)
            _dir.Normalize();

        if ((hAxie != 0 || vAxie != 0) && isRunning)
            _cameraController.ChangeRunningFOV(1);
        else
            _cameraController.ChangeRunningFOV(0);

        _physics.ApplyConstantForce("movement", _dir, _actualSpeed, 0);
    }

    Vector3 AlignDir()
    {
        RaycastHit hit;
        Vector3 planeNormal;

        if (Physics.Raycast(transform.position, transform.up * -1, out hit, 1.5f, _floorMask))
            planeNormal = hit.normal;
        else
            return _dir;

        // Use Vector3.ProjectOnPlane to align the direction with the plane
        Vector3 alignedDirection = Vector3.ProjectOnPlane(_dir, planeNormal);
        return alignedDirection;
    }

    public void Jump()
    {
        if (_jumpCounter > 1) return;
        if (Physics.Raycast(transform.position - Vector3.up, Vector3.up, 2f, _floorMask)) return;

        if (_canJump)
        {
            if (_jumpCoroutine != null)
                StopCoroutine(_jumpCoroutine);

            _jumpCoroutine = StartCoroutine(JumpDuration());

            _physics.RemoveAcceleration("gravity");

            _physics.ApplyImpulse("jump", Vector3.up, _jumpForce, _jumpDesacceleration);

            _canJump = false;
            _jumpCounter++;
        }
        else
        {
            Collider[] collisions = Physics.OverlapSphere(transform.position, 1, _wallMask);

            if (!collisions.Any()) return;

            if (_jumpCoroutine != null)
                StopCoroutine(_jumpCoroutine);

            if (_walljumpCoroutine != null)
                StopCoroutine(_walljumpCoroutine);

            _jumpCoroutine = StartCoroutine(JumpDuration());
            _walljumpCoroutine = StartCoroutine(WallJumpDuration());

            Collider[] orderCollisions =
                collisions.OrderBy(x => Vector3.Distance(transform.position, x.transform.position)).ToArray();
            Collider closeCollider = orderCollisions.First();


            _physics.RemoveAcceleration("gravity");

            _physics.ApplyImpulse("walljump",
                (closeCollider.ClosestPoint(transform.position) - transform.position).normalized * -1, _walljumpForce,
                _wallJumpDesacceleration);
            _physics.ApplyImpulse("jump", Vector3.up, _jumpForce, _jumpDesacceleration);

            _canJump = false;
            _jumpCounter++;
        }
    }

    public void Slide()
    {
        _actualCollider.SetActive(false);
        _actualCollider = _posibleColliders[1];
        _actualCollider.SetActive(true);

        isCrouch = true;
        _actualSpeed = _slideSpeed;
        isSlide = true;

        if (_slideCoroutine != null)
            StopCoroutine(_slideCoroutine);

        _slideCoroutine = StartCoroutine(SlideTime());
    }

    public void Crouch(int state)
    {
        if (state == 1)
        {
            crouchChecker = delegate { };

            _actualCollider.SetActive(false);
            _actualCollider = _posibleColliders[state];
            _actualCollider.SetActive(true);

            isCrouch = true;

            if (Physics.Raycast(transform.position, transform.up * -1, 1.5f, _floorMask))
                _actualSpeed = _crunchSpeed;

            Run(0);

        }
        else
        {
            if (Physics.Raycast(transform.position - Vector3.up, Vector3.up, 2f, _floorMask))
            {
                crouchChecker = CheckRoof;
            }
            else
            {
                crouchChecker = delegate { };
                
                _actualCollider.SetActive(false);
                _actualCollider = _posibleColliders[state];
                _actualCollider.SetActive(true);

                if (Physics.Raycast(transform.position, transform.up * -1, 1.5f, _floorMask))
                    _actualSpeed = _walkingSpeed;
                isCrouch = false;
            }
        }
    }

    public void Run(int state)
    {
        if (isCrouch && state == 1) return;

        if (state == 1)
        {
            isRunning = true;
        }
        else
        {
            isRunning = false;
        }

        if (!isCrouch)
        {
            if (state == 1)
            {
                if (Physics.Raycast(transform.position, transform.up * -1, 1.5f, _floorMask))
                    _actualSpeed = _runningSpeed;
            }
            else
            {
                if (Physics.Raycast(transform.position, transform.up * -1, 1.5f, _floorMask))
                    _actualSpeed = _walkingSpeed;
            }
        }
    }

    void SetAssistant(params object[] parameters)
    {
        _assistant = (Assistant)parameters[0];
    }

    IEnumerator SlideTime()
    {
        SoundManager.instance.PlaySound(SoundID.SLIDE);
        yield return new WaitForSeconds(_slideDuration / 2);

        LeanTween.cancel(gameObject);

        LeanTween.value(_actualSpeed, _runningSpeed, _slideDuration / 2).setOnUpdate((float value) =>
        {
            _actualSpeed = value;
        });

        yield return new WaitForSeconds(_slideDuration / 2);

        _cameraController.ChangeRunningFOV(0);

        if (isCrouch) _actualSpeed = _crunchSpeed;
        else if (!isRunning) _actualSpeed = _walkingSpeed;
    }

    IEnumerator CoyoteTime()
    {
        yield return new WaitForSeconds(_coyoteTime);
        _canJump = false;
    }

    IEnumerator JumpDuration()
    {
        yield return new WaitForSeconds(_jumpDuration);

        _physics.RemoveImpulse("jump");
        _physics.ApplyAcceleration("gravity", Vector3.down, _gravity, Mathf.Infinity);
        _jumpCoroutine = null;
    }

    IEnumerator WallJumpDuration()
    {
        yield return new WaitForSeconds(_walljumpDuration);

        _physics.RemoveImpulse("walljump");
        _walljumpCoroutine = null;
    }

    void CheckOnFloor()
    {
        if (_jumpCoroutine == null && !Physics.CheckBox(transform.position - Vector3.up, new Vector3(0.7f, 0.2f, 0.7f),
                transform.rotation, _floorMask))
        {
            if (_coyoteTimeCoroutine != null)
                StopCoroutine(_coyoteTimeCoroutine);

            if (_slideCoroutine != null)
                StopCoroutine(_slideCoroutine);

            _isOnFloor = false;

            _coyoteTimeCoroutine = StartCoroutine(CoyoteTime());

            _physics.ApplyAcceleration("gravity", Vector3.down, _gravity, Mathf.Infinity);
            ;
            floorChecker = CheckOffFloor;
        }
    }

    void CheckOffFloor()
    {
        if (Physics.CheckBox(transform.position - Vector3.up, new Vector3(0.7f, 0.2f, 0.7f), transform.rotation,
                _floorMask))
        {
            if (_coyoteTimeCoroutine != null)
                StopCoroutine(_coyoteTimeCoroutine);

            if (_jumpCoroutine != null)
                StopCoroutine(_jumpCoroutine);

            _canJump = true;
            _jumpCounter = 0;

            _isOnFloor = true;

            SoundManager.instance.PlaySound(SoundID.JUMP_LANDING);

            if (isSlide)
                _slideCoroutine = StartCoroutine(SlideTime());

            _physics.RemoveAcceleration("gravity");

            floorChecker = CheckOnFloor;
        }
    }

    void CheckRoof()
    {
        if (!Physics.Raycast(transform.position - transform.up, Vector3.up, 1.1f, _floorMask))
        {
            Crouch(0);
        }
    }


    public void Health(int healthAmmount)
    {
        _life += healthAmmount;
        _life = Mathf.Clamp(_life, 0, _maxLife);

        EventManager.Trigger("ChangeHealthUI", _life);
    }

    public void GetDamage(int dmg)
    {
        if (!_canGetDmg || currentDmgCooldown >= 0) return;
        if (_life <= 0) return;

        _life -= dmg;

        _life = Mathf.Clamp(_life, 0, _maxLife);
        EventManager.Trigger("ChangeHealthUI", _life);

        //TODO: Add SFX and VFX for player dmg
        if (SoundManager.instance != null)
            SoundManager.instance.PlaySound(SoundID.PLAYER_HURT);

        currentDmgCooldown = dmgCooldown;

        EventManager.Trigger("OnPlayerTakeDamage");

        if (_life <= 0)
        {
            Death();
        }
    }

    void Death()
    {
        //TODO: Add death reset
        GameManager.Instance.ReloadScene();
    }

    //TODO: Delete when you add the dmg to the enemies
    void CheckDmg()
    {
        if (Input.GetKeyDown(KeyCode.U))
        {
            int dmg = UnityEngine.Random.Range(2, 10);
            GetDamage(dmg);
        }
        else if (Input.GetKeyDown(KeyCode.I))
        {
            int health = UnityEngine.Random.Range(2, 10);
            Health(health);
        }
        else if (Input.GetKeyDown(KeyCode.Y))
        {
            _canGetDmg = !_canGetDmg;
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawWireCube(transform.position - Vector3.up, new Vector3(0.7f, 0.2f, 0.7f));
        Gizmos.DrawLine(transform.position, transform.position + _dir.normalized * 5);
        Gizmos.color = Color.blue;
        Gizmos.DrawLine(transform.position, transform.position + transform.up * -1.1f);
    }
}