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
    [SerializeField] float _crunchSpeed;

    [SerializeField] float _jumpForce;

    bool _isCrunch = false;

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

        _dir *= +_actualSpeed * Time.fixedDeltaTime;

        _dir.y = _rb.velocity.y;
    }

    public void Jump()
    {
        if (_canJump)
        {
            _rb.AddForce(transform.up * _jumpForce);
        }
    }

    public void Crunch(int state)
    {
        _actualCollider.SetActive(false);
        _actualCollider = _posibleColliders[state];
        _actualCollider.SetActive(true);

        if (state == 1)
        {
            _actualSpeed = _crunchSpeed;

            Run(0);

            _isCrunch = true;
        }
        else
        {
            _actualSpeed = _walkingSpeed;
            _isCrunch = false;
        }
    }

    public void Run(int state)
    {
        if (_isCrunch) return;

        if (state == 1)
            _actualSpeed = _runningSpeed;
        else
            _actualSpeed = _walkingSpeed;
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
            _canJump = false;
        }
    }
}
