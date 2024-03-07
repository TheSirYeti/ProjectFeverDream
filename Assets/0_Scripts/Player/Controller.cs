using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class Controller
{
    private readonly Model _model;
    private readonly CameraController _cameraController;
    private readonly WeaponManager _weaponManager;

    public Action OnUpdate = delegate { };

    public Controller(Model model, CameraController cameraController, WeaponManager weaponManager)
    {
        _model = model;
        _cameraController = cameraController;
        _weaponManager = weaponManager;

        OnUpdate += GetMouse;
        OnUpdate += GetShootInput;
        OnUpdate += GetReloadInput;
        OnUpdate += GetADSInput;
        OnUpdate += GetMovementInput;
        OnUpdate += GetJumpInput;
        OnUpdate += GetCrunchInput;
        OnUpdate += GetRunInput;
        OnUpdate += GetInteractInput;
        
    }

    private void GetMouse()
    {
        _cameraController.MoveCamera(Input.GetAxis("Mouse X"), Input.GetAxis("Mouse Y"));
    }

    private void GetShootInput()
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

    private void GetADSInput()
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

    private void GetReloadInput()
    {
        if (Input.GetKeyDown(KeyCode.R))
        {
            _weaponManager.AnimReload();
        }
    }
    
    private void GetMovementInput()
    {
        var h = Input.GetAxisRaw("Horizontal");
        var v = Input.GetAxisRaw("Vertical");

        _model.Move(h, v);
    }

    private void GetJumpInput()
    {
        if (Input.GetButtonDown("Jump"))
            _model.Jump();
    }

    private void GetCrunchInput()
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
            _model._actualCameraPoint = _model.PovsGetter[1];
        }
        else if (Input.GetKeyUp(KeyCode.LeftControl))
        {
            _model.Crouch(0);
            
        }
    }

    private void GetRunInput()
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

    private void GetInteractInput()
    {
        if (Input.GetKeyDown(KeyCode.F))
        {
            _cameraController.cameraAim.Interact();
        }
        
        if (Input.GetKeyDown(KeyCode.T))
        {
            GameManager.Instance.Assistant.ResetGeorge();
        }
    }
}
