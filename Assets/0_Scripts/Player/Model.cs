using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Model : MonoBehaviour
{
    //Class Reference
    Controller _controller;
    View _view;
    WeaponManager _weaponManager;
    CameraController _cameraController;
    Assistant _assistant;

    //Component Reference
    Rigidbody _rb;
    Camera _camera;

    [Space(20)]
    [Header("-== Physics Properties ==-")]
    [SerializeField] float _gravity = -10f;
    float _actualYVelocity = 0;

    [Space(20)]
    [Header("-== Movement Properties ==-")]
    float _actualSpeed;
    [SerializeField] float _walkingSpeed;
    [SerializeField] float _runningSpeed;
    [SerializeField] float _slideSpeed;
    [SerializeField] float _crunchSpeed;
    [SerializeField] float _slideDuration;

    [Space(20)]
    [Header("-== Interact Properties ==-")]
    [SerializeField] float _interactDistance;
    [SerializeField] LayerMask _interactMask;

    [Space(20)]
    [Header("-== Jump Properties ==-")]
    [SerializeField] float _jumpDuration;
    [SerializeField] float _jumpForce;
    [SerializeField] float _coyoteTime;
    [SerializeField] LayerMask _floorMask;
    [SerializeField] LayerMask _wallMask;

    Coroutine _coyoteTimeCoroutine;

    // Movement Bools
    public bool isCrunch { get; private set; } = false;
    public bool isRunning { get; private set; } = false;
    public bool isSlide { get; private set; } = false;

    int _jumpCounter = 0;
    bool _canJump = false;
    bool _isOnFloor = false;

    // Coroutines
    Coroutine _slideCoroutine;
    Coroutine _jumpCoroutine;

    // Dir Vector
    Vector3 _dir = Vector3.zero;
    [SerializeField] float _h = 0;

    // Colliders
    List<GameObject> _posibleColliders = new List<GameObject>();
    GameObject _actualCollider;

    private void Awake()
    {
        _view = FindObjectOfType<View>();
        _weaponManager = FindObjectOfType<WeaponManager>();

        _camera = Camera.main;

        _weaponManager.SetRef(this, _camera.transform, _view);
        _cameraController = GetComponent<CameraController>();
        _controller = new Controller(this, _cameraController, _weaponManager);
        _rb = GetComponent<Rigidbody>();

        Transform povParent = transform.Find("Colliders");

        foreach (Transform child in povParent)
        {
            _posibleColliders.Add(child.gameObject);
            child.gameObject.SetActive(false);
        }

        _actualCollider = _posibleColliders[0];
        _actualCollider.SetActive(true);

        _actualSpeed = _walkingSpeed;

        ApplyVerticalVelocity(_gravity);

        EventManager.Subscribe("SetAssistant", SetAssistant);
    }

    void Start()
    {
        EventManager.Trigger("OnAssistantStart", _camera.transform);
        EventManager.Trigger("OnViewStart", this, _weaponManager);
    }

    void Update()
    {
        _controller.onUpdate();

        if(Physics.Raycast(transform.position, transform.up * -1, 1.5f, _floorMask))
        {
            _jumpCounter = 0;
            _canJump = true;
        }
    }

    void FixedUpdate()
    {
        _rb.velocity = _dir;

        _rb.AddForce(Vector3.up * _actualYVelocity, ForceMode.Force);
    }

    public void Move(float hAxie, float vAxie)
    {
        _h = hAxie;
        _dir = (transform.right * hAxie + transform.forward * vAxie);

        _dir = AlignDir();


        if (_dir.magnitude > 1)
            _dir.Normalize();

        _dir *= _actualSpeed * Time.fixedDeltaTime;

        _dir.y = _rb.velocity.y;

        //if (_actualYVelocity != 0 && _dir.y > 0 && hAxie == 0 && vAxie == 0) _dir.y = 0;

        if ((hAxie != 0 || vAxie != 0) && isRunning)
            _cameraController.ChangeRunningFOV(1);
        else
            _cameraController.ChangeRunningFOV(0);
    }

    Vector3 AlignDir()
    {
        RaycastHit hit;
        Vector3 planeNormal;

        if (Physics.Raycast(transform.position, transform.up * -1, out hit, 1.5f, _floorMask))
            planeNormal = hit.collider.transform.up;
        else
            return _dir;

        // Use Vector3.ProjectOnPlane to align the direction with the plane
        Vector3 alignedDirection = Vector3.ProjectOnPlane(_dir, planeNormal);
        return alignedDirection;
    }

    public void Jump()
    {
        if ((_canJump 
            || Physics.Raycast(transform.position, transform.up * -1, 1.5f, _floorMask) 
            || Physics.Raycast(transform.position, transform.right * _h, 1, _wallMask))
            && _jumpCounter < 2
            )
        {
            if (_jumpCoroutine != null)
                StopCoroutine(_jumpCoroutine);

            _jumpCoroutine = StartCoroutine(JumpDuration());

            ApplyVerticalVelocity(0);

            Vector3 velocity = _rb.velocity;
            velocity.y = 0;
            _rb.velocity = velocity;
            _rb.angularVelocity = Vector3.zero;

            _rb.AddForce(Vector3.up * _jumpForce, ForceMode.Impulse);

            _canJump = false;
            _jumpCounter++;
        }
    }

    public void Slide()
    {
        isCrunch = true;
        _actualSpeed = _slideSpeed;
        isSlide = true;

        if (_slideCoroutine != null)
            StopCoroutine(_slideCoroutine);

        if (_isOnFloor)
            _slideCoroutine = StartCoroutine(SlideTime());
    }

    public void Crouch(int state)
    {
        _actualCollider.SetActive(false);
        _actualCollider = _posibleColliders[state];
        _actualCollider.SetActive(true);

        if (state == 1)
        {
            Run(0);

            if (Physics.Raycast(transform.position, transform.up * -1, 1.5f, _floorMask))
                _actualSpeed = _crunchSpeed;


            isCrunch = true;
        }
        else
        {
            if (Physics.Raycast(transform.position, transform.up * -1, 1.5f, _floorMask))
                _actualSpeed = _walkingSpeed;
            isCrunch = false;
        }
    }

    public void Run(int state)
    {
        if (isCrunch && state == 1) return;

        if (state == 1)
        {
            isRunning = true;
        }
        else
        {
            isRunning = false;
        }

        if (!isCrunch)
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

    public void CheckInteract()
    {
        RaycastHit hit;
        if (Physics.Raycast(Camera.main.transform.position, Camera.main.transform.forward, out hit, _interactDistance, _interactMask))
        {
            IAttendance iAttendance = hit.collider.gameObject.GetComponent<IAttendance>();

            if (iAttendance == null || !iAttendance.CanInteract()) return;

            _assistant.SetObjective(iAttendance);
        }
    }

    void ApplyVerticalVelocity(float newVelocity)
    {
        _actualYVelocity = newVelocity;
    }

    void SetAssistant(params object[] parameters)
    {
        _assistant = (Assistant)parameters[0];
    }

    IEnumerator SlideTime()
    {
        yield return new WaitForSeconds(_slideDuration / 2);

        LeanTween.cancel(gameObject);

        LeanTween.value(_actualSpeed, _runningSpeed, _slideDuration / 2).setOnUpdate((float value) =>
        {
            _actualSpeed = value;
        });

        yield return new WaitForSeconds(_slideDuration / 2);

        _cameraController.ChangeRunningFOV(0);

        if (isCrunch) _actualSpeed = _crunchSpeed;
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
        ApplyVerticalVelocity(_gravity);
        _jumpCoroutine = null;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Floor")
        {
            if (_coyoteTimeCoroutine != null)
                StopCoroutine(_coyoteTimeCoroutine);

            _canJump = true;
            _jumpCounter = 0;

            _isOnFloor = true;

            if (isSlide)
                _slideCoroutine = StartCoroutine(SlideTime());
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.tag == "Floor")
        {
            if (_coyoteTimeCoroutine != null)
                StopCoroutine(_coyoteTimeCoroutine);

            if (_slideCoroutine != null)
                StopCoroutine(_slideCoroutine);

            _isOnFloor = false;

            _coyoteTimeCoroutine = StartCoroutine(CoyoteTime());
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawLine(transform.position, transform.position + _dir.normalized * 10);
        Gizmos.DrawLine(transform.position, transform.position + transform.right * _h);
    }
}
