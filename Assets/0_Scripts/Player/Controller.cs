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
            float h = Input.GetAxis("Horizontal");
            float v = Input.GetAxis("Vertical");

            Debug.Log(h);

            if (h > 0)
                h = 1;
            else if(h < 0)
                h = -1;

            if (v > 0)
                v = 1;
            else if (v < 0)
                v = -1;

            _model.Move(h, v);
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
