using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class Controller
{
    Model _model;
    CameraController _cameraController;
    WeaponManager _weaponManager;

    public Action onUpdate = delegate { };

    public Controller(Model model, CameraController cameraController, WeaponManager weaponManager)
    {
        _model = model;
        _cameraController = cameraController;
        _weaponManager = weaponManager;

        onUpdate += GetMouse;
        onUpdate += GetShootInput;
        onUpdate += GetADSInput;
        onUpdate += GetMovementInput;
        onUpdate += GetJumpInput;
        onUpdate += GetCrunchInput;
        onUpdate += GetRunInput;
        onUpdate += GetInteractInput;
        onUpdate += GetEscape;
    }

    void GetMouse()
    {
        _cameraController.MoveCamera(Input.GetAxis("Mouse X"), Input.GetAxis("Mouse Y"));
    }

    void GetShootInput()
    {
        if (Input.GetKeyDown(KeyCode.Mouse0))
        {
            _weaponManager.ChangeAttackState(true);
        }
        else if (Input.GetKeyUp(KeyCode.Mouse0))
        {
            _weaponManager.ChangeAttackState(false);
        }
    }

    void GetADSInput()
    {
        if (Input.GetKeyDown(KeyCode.Mouse1))
        {
            _weaponManager.ChangeADSState(true);
        }
        else if (Input.GetKeyUp(KeyCode.Mouse1))
        {
            _weaponManager.ChangeADSState(false);
        }
    }

    void GetMovementInput()
    {
        float h = 0;
        float v = 0;

        if (Input.GetKey(KeyCode.A))
            h = -1;
        else if (Input.GetKey(KeyCode.D))
            h = 1;

        if (Input.GetKey(KeyCode.W))
            v = 1;
        else if (Input.GetKey(KeyCode.S))
            v = -1;

        _model.Move(h, v);
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
            if (_model.isRunning)
            {
                _model.Slide();
            }
            else
            {
                _model.Crouch(1);
                _cameraController.ChangeRunningFOV(0);
            }

            _cameraController.StartTranslate(1);
        }
        else if (Input.GetKeyUp(KeyCode.LeftControl))
        {
            _model.Crouch(0);
            _cameraController.StartTranslate(0);
        }
    }

    void GetRunInput()
    {
        if (Input.GetKeyDown(KeyCode.LeftShift))
        {
            _model.Run(1);
        }
        else if (Input.GetKeyUp(KeyCode.LeftShift))
        {
            _model.Run(0);
        }
    }

    void GetInteractInput()
    {
        if (Input.GetKeyDown(KeyCode.F))
        {
            _model.CheckInteract();
        }
    }

    void GetEscape()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            EventManager.Trigger("TempMenu");
        }
    }
}
