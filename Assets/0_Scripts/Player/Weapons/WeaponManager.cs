using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class WeaponManager : GenericObject, IAssistInteract
{
    Model _model;
    [HideInInspector] public View _view;
    [SerializeField] RuntimeAnimatorController _noWeaponAnimator;

    [SerializeField] int _usableID;

    [Serializable]
    public struct WeaponRenderer
    {
        public List<Renderer> _myRenders;
    }

    [SerializeField] List<WeaponRenderer> _weaponsRenderer;


    [SerializeField] GenericWeapon _actualWeapon;
    [SerializeField] GenericWeapon _handWeapon;

    [SerializeField] Transform _nozzlePoint;
    Transform _pointOfShoot => _model._actualCameraPoint;
    bool _isADS;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }
    
    public override void OnStart()
    {
        if (_actualWeapon)
        {
            if (!_actualWeapon._isHandWeapon)
            {
                foreach (Renderer item in _weaponsRenderer[_actualWeapon.GetID()]._myRenders)
                {
                    item.enabled = true;
                }
            }

            _actualWeapon.OnWeaponEquip(transform, this, _nozzlePoint);
            
            _view.SetAnimatorController(_actualWeapon.GetAnimatorController());
        }
    }

    public void SetRef(Model model, Transform pointOfShoot, View view)
    {
        _model = model;
        _view = view;
    }

    public void ChangeAttackState(bool state)
    {
        if (_actualWeapon == null) return;

        if (_actualWeapon.CanShoot() && state)
        {
            _actualWeapon.OnClick();
        }
        else if (!state)
        {
            _actualWeapon.OnRelease();
        }
    }

    public void ChangeADSState(bool state)
    {
        _isADS = state;
    }

    public void ExecuteShoot()
    {
        _actualWeapon.Shoot(_pointOfShoot, _isADS);
    }

    public void AnimReload()
    {
        if (!_actualWeapon || !_actualWeapon.CanReload()) return;

        _view.SetTrigger("reload");
    }

    public void ExecuteReload()
    {
        _view.ResetTrigger("reload");
        _actualWeapon.Reload();
    }

    public void EquipWeapon(GenericWeapon newWeapon, bool turnOffPrevious = true, bool isFromTheFloor = false, bool changeRenderer = true)
    {
        if (_actualWeapon != null && turnOffPrevious)
        {
            _actualWeapon.OnWeaponUnequip();

            //foreach (Renderer item in _weaponsRenderer[_actualWeapon.GetID()]._myRenders)
            //{
            //    item.enabled = false;
            //}
        }

        if (changeRenderer)
        {
            foreach (WeaponRenderer weaponStruct in _weaponsRenderer)
            {
                foreach (Renderer render in weaponStruct._myRenders)
                {
                    render.enabled = false;
                }
            }
        }

        _actualWeapon = newWeapon;

        if (changeRenderer)
        {
            foreach (Renderer item in _weaponsRenderer[_actualWeapon.GetID()]._myRenders)
            {
                item.enabled = true;
            }
        }
        
        _actualWeapon.OnWeaponEquip(transform, this, _nozzlePoint);
        
        _view.SetAnimatorController(_noWeaponAnimator);
        _view.SetAnimatorController(_actualWeapon.GetAnimatorController());

        if(isFromTheFloor && _actualWeapon.GetID() == 1)
        {
            _view.PlayAnimation("ANIM_Player_BaguetteDUAL_Idle");
        }
    }

    public void DestroyWeapon()
    {
        foreach (Renderer item in _weaponsRenderer[_actualWeapon.GetID()]._myRenders)
        {
            item.enabled = false;
        }

        Destroy(_actualWeapon.gameObject);

        _actualWeapon = _handWeapon;
        
        _actualWeapon.OnWeaponEquip(transform, this, _nozzlePoint);
        
        _view.SetAnimatorController(_noWeaponAnimator);
        _view.SetAnimatorController(_actualWeapon.GetAnimatorController());
        
        EventManager.Trigger("ChangeEquipedWeapontUI", -1);
        EventManager.Trigger("ChangeBulletUI", 0, 0);
    }

    public void ChangeRenderer()
    { 
        foreach (var weaponStruct in _weaponsRenderer)
        {
            foreach (var render in weaponStruct._myRenders)
            {
                render.enabled = false;
            }
        }
        
        foreach (var item in _weaponsRenderer[_actualWeapon.GetID()]._myRenders)
        {
            item.enabled = true;
        }
    }

    public void Interact(IAssistInteract usableItem = null)
    {
        EquipWeapon(usableItem.GetTransform().gameObject.GetComponent<GenericWeapon>(), true, true);
    }

    public Interactuables GetInteractType()
    {
        return Interactuables.WEAPONMANAGER;
    }

    public Assistant.JorgeStates GetState()
    {
        throw new NotImplementedException();
    }

    public Transform GetTransform()
    {
        return transform;
    }

    public Transform GetInteractPoint()
    {
        return transform;
    }

    public List<Renderer> GetRenderer()
    {
        throw new NotImplementedException();
    }

    public bool CanInteract()
    {
        return true;
    }

    public string ActionName()
    {
        return "Equip";
    }

    public string AnimationToExecute()
    {
        throw new NotImplementedException();
    }

    public void ChangeOutlineState(bool state)
    {
        throw new NotImplementedException();
    }

    public bool CanInteractWith(IAssistInteract assistInteract)
    {
        return assistInteract is GenericWeapon ? true : false;
    }

    public bool IsAutoUsable()
    {
        return false;
    }

    public Transform GoesToUsablePoint()
    {
        throw new NotImplementedException();
    }
}
