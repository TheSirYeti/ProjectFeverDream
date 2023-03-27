using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Model : MonoBehaviour
{
    Controller _controller;
    CameraController _cameraController;

    Rigidbody _rb;

    float _actualSpeed;
    [SerializeField] float _walkingSpeed;
    [SerializeField] float _runningSpeed;
    [SerializeField] float _slideSpeed;
    [SerializeField] float _crunchSpeed;

    [SerializeField] float _slideDuration;

    [SerializeField] float _jumpForce;
    [SerializeField] float _coyoteTime;

    Coroutine _coyoteTimeCoroutine;

    public bool isCrunch { get; private set; } = false;
    public bool isRunning { get; private set; } = false;

    bool _canJump = false;

    Vector3 _dir = Vector3.zero;

    List<GameObject> _posibleColliders = new List<GameObject>();
    GameObject _actualCollider;

    private void Awake()
    {
        _cameraController = GetComponent<CameraController>();
        _controller = new Controller(this, _cameraController);
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

        Vector3 newGravity = Physics.gravity;
        newGravity.y = -20;
        Physics.gravity = newGravity;
    }

    void Update()
    {
        _controller.onUpdate();
    }

    private void FixedUpdate()
    {
        _rb.velocity = _dir;
    }

    public void Move(float hAxie, float vAxie)
    {
        _dir = (transform.right * hAxie + transform.forward * vAxie);

        if (_dir.magnitude > 1)
            _dir.Normalize();

        _dir *= _actualSpeed * Time.fixedDeltaTime;

        _dir.y = _rb.velocity.y;
    }

    public void Jump()
    {
        if (_canJump)
        {
            Vector3 velocity = _rb.velocity;
            velocity.y = 0;
            _rb.velocity = velocity;

            _rb.AddForce(transform.up * _jumpForce);

            _canJump = false;
        }
    }

    public void Slide()
    {
        _actualSpeed = _slideSpeed;
        StartCoroutine(SlideTime());
    }

    public void Crouch(int state)
    {
        _actualCollider.SetActive(false);
        _actualCollider = _posibleColliders[state];
        _actualCollider.SetActive(true);

        if (state == 1)
        {
            _actualSpeed = _crunchSpeed;

            Run(0);

            isCrunch = true;
        }
        else
        {
            _actualSpeed = _walkingSpeed;
            isCrunch = false;
        }
    }

    public void Run(int state)
    {
        if (isCrunch) return;

        if (state == 1)
        {
            _actualSpeed = _runningSpeed;
            isRunning = true;
        }
        else
        {
            _actualSpeed = _walkingSpeed;
            isRunning = false;
        }
    }

    IEnumerator SlideTime()
    {
        yield return new WaitForSeconds(_slideDuration / 2);

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

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Floor")
        {
            _canJump = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.tag == "Floor")
        {
            if (_coyoteTimeCoroutine != null)
                StopCoroutine(_coyoteTimeCoroutine);

            _coyoteTimeCoroutine = StartCoroutine(CoyoteTime());
        }
    }
}
