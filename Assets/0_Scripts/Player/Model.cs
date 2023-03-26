using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Model : MonoBehaviour
{
    Controller _controller;
    CameraController _cameraController;

    Rigidbody _rb;

    [SerializeField] float _speed;
    [SerializeField] float _jumpForce;

    bool canJump = false;

    Vector3 _dir = Vector3.zero;

    List<GameObject> _posibleColliders = new List<GameObject>();

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

        _posibleColliders[0].SetActive(true);
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

        _dir *= _speed * Time.fixedDeltaTime;

        _dir.y = _rb.velocity.y;
    }

    public void Jump()
    {
        if (CheckFloor())
        {
            _rb.AddForce(transform.up * _jumpForce);
        }
    }

    bool CheckFloor()
    {
        return canJump;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Floor")
        {
            canJump = true;
        }
    }

    private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.tag == "Floor")
        {
            canJump = false;
        }
    }
}
