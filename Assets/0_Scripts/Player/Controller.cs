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
        onUpdate += GetCrunchInput;
        onUpdate += GetRunInput;
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

    void GetCrunchInput()
    {
        if (Input.GetKeyDown(KeyCode.LeftControl))
        {
            _model.Crunch(1);
            _cameraController.StartTranslate(1);
        }
        else if (Input.GetKeyUp(KeyCode.LeftControl))
        {
            _model.Crunch(0);
            _cameraController.StartTranslate(0);
        }
    }

    void GetRunInput()
    {
        if (Input.GetKeyDown(KeyCode.LeftShift))
        {
            _model.Run(1);
            _cameraController.ChangeFOV(1);
        }
        else if (Input.GetKeyUp(KeyCode.LeftShift))
        {
            _model.Run(0);
            _cameraController.ChangeFOV(0);
        }
    }
}
