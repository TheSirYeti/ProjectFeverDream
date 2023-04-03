using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Model : MonoBehaviour
{
    [Header("-== Class Reference ==-")]
    Controller _controller;
    [SerializeField] View _view;
    [SerializeField] WeaponManager _weaponManager;
    CameraController _cameraController;
    Assistant _assistant;

    //Component Reference
    Rigidbody _rb;
    Camera _camera;

    [Space(20)] [Header("-== Physics Properties ==-")]
    [SerializeField] float _gravity = -10f;
    float _actualYVelocity = 0;

    [Space(20)] [Header("-== Movement Properties ==-")]
    float _actualSpeed;
    [SerializeField] float _walkingSpeed;
    [SerializeField] float _runningSpeed;
    [SerializeField] float _slideSpeed;
    [SerializeField] float _crunchSpeed;
    [SerializeField] float _slideDuration;

    [Space(20)] [Header("-== Interact Properties ==-")]
    [SerializeField] float _interactDistance;
    [SerializeField] LayerMask _interactMask;

    [Space(20)] [Header("-== Jump Properties ==-")]
    [SerializeField] float _jumpDuration;
    [SerializeField] float _jumpForce;
    [SerializeField] float _coyoteTime;
    [SerializeField] LayerMask _floorMask;

    Coroutine _coyoteTimeCoroutine;

    // Movement Bools
    public bool isCrunch { get; private set; } = false;
    public bool isRunning { get; private set; } = false;
    public bool isSlide { get; private set; } = false;

    bool _canJump = false;
    bool _isOnFloor = false;

    // Coroutines
    Coroutine _slideCoroutine;
    Coroutine _jumpCoroutine;

    // Dir Vector
    Vector3 _dir = Vector3.zero;

    // Colliders
    List<GameObject> _posibleColliders = new List<GameObject>();
    GameObject _actualCollider;

    private void Awake()
    {
        _camera = Camera.main;

        _weaponManager.OnStart(this, _camera.transform, _view);
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
        EventManager.Trigger("OnAssistantStart", transform);
        EventManager.Trigger("OnViewStart", this, _weaponManager);
    }

    void Update()
    {
        _controller.onUpdate();
    }

    void FixedUpdate()
    {
        _rb.AddForce(Vector3.up * _actualYVelocity, ForceMode.Acceleration);
        _rb.velocity = _dir;
    }

    public void Move(float hAxie, float vAxie)
    {
        _dir = (transform.right * hAxie + transform.forward * vAxie);

        if (_dir.magnitude > 1)
            _dir.Normalize();

        _dir *= _actualSpeed * Time.fixedDeltaTime;

        _dir.y = _rb.velocity.y;

        if ((hAxie != 0 || vAxie != 0) && isRunning)
            _cameraController.ChangeRunningFOV(1);
        else
            _cameraController.ChangeRunningFOV(0);
    }

    public void Jump()
    {
        if (_canJump || Physics.Raycast(transform.position, transform.up * - 1, 1f, _floorMask))
        {
            if (_jumpCoroutine != null)
                StopCoroutine(_jumpCoroutine);

            _jumpCoroutine = StartCoroutine(JumpDuration());

            _rb.AddForce(Vector3.up * _jumpForce, ForceMode.Impulse);

            _canJump = false;
        }
    }

    public void Slide()
    {
        isCrunch = true;
        _actualSpeed = _slideSpeed;
        isSlide = true;

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

            _isOnFloor = true;

            ApplyVerticalVelocity(0);

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

            if (_jumpCoroutine == null)
                ApplyVerticalVelocity(_gravity);

            _coyoteTimeCoroutine = StartCoroutine(CoyoteTime());
        }
    }
}
