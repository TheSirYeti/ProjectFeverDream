using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class Controller
{
    Model _model;
    CameraController _cameraController;

    public Action onUpdate = delegate { };

    public Controller(Model model, CameraController cameraController)
    {
        _model = model;
        _cameraController = cameraController;

        onUpdate += GetMouse;
        onUpdate += GetMovementInput;
        onUpdate += GetJumpInput;
    }

    void GetMouse()
    {
        _cameraController.MoveCamera(Input.GetAxis("Mouse X"), Input.GetAxis("Mouse Y"));
    }

    void GetMovementInput()
    {
        if (Input.GetButton("Movement"))
        {
            _model.Move(Input.GetAxis("Horizontal"), Input.GetAxis("Vertical"));
        }
        else
            _model.Move(0, 0);
    }

    void GetJumpInput()
    {
        if (Input.GetButtonDown("Jump"))
            _model.Jump();
    }
}
