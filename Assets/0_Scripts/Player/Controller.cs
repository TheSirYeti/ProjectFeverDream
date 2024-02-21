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
        //onUpdate += GetNumsInput;
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

    //void GetNumsInput()
    //{
    //    if (Input.GetKeyDown(KeyCode.Alpha1))
    //    {
    //        _weaponManager.ChangeWeapon(0);
    //    }
    //    else if (Input.GetKeyDown(KeyCode.Alpha2))
    //    {
    //        _weaponManager.ChangeWeapon(1);
    //    }
    //    else if (Input.GetKeyDown(KeyCode.Alpha3))
    //    {
    //        _weaponManager.ChangeWeapon(2);
    //    }
    //}

    private void GetMovementInput()
    {
        var h = Input.GetAxisRaw("Horizontal");
        var v = Input.GetAxisRaw("Vertical");

        // if (Input.GetKey(KeyCode.A))
        //     h = -1;
        // else if (Input.GetKey(KeyCode.D))
        //     h = 1;
        //
        // if (Input.GetKey(KeyCode.W))
        //     v = 1;
        // else if (Input.GetKey(KeyCode.S))
        //     v = -1;

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
    }
}
