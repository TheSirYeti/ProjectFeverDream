using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Model : MonoBehaviour
{
    Controller _controller;

    Rigidbody _rb;

    [SerializeField] float _speed;
    [SerializeField] float _jumpForce;

    [SerializeField] LayerMask _floorMask;

    Vector3 _dir = Vector3.zero;

    void Start()
    {
        _controller = new Controller(this, GetComponent<CameraController>());
        _rb = GetComponent<Rigidbody>();
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
            Debug.Log("a");
            _rb.AddForce(transform.up * _jumpForce);
        }
    }

    bool CheckFloor()
    {
        if (Physics.Raycast(transform.position, transform.up * -1, 1, _floorMask))
            return true;
        else
            return false;
    }
}
