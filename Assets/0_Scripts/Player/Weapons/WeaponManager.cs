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

    [SerializeField] Transform _nozzlePoint;
    Transform _pointOfShoot;
    bool _isADS;

    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }
    
    public override void OnStart()
    {
        if (_actualWeapon)
        {
            foreach (Renderer item in _weaponsRenderer[_actualWeapon.GetID()]._myRenders)
            {
                item.enabled = true;
            }

            _actualWeapon.OnWeaponEquip(transform, this, _nozzlePoint);
            
            _view.SetAnimatorController(_actualWeapon.GetAnimatorController());
        }
    }

    public void SetRef(Model model, Transform pointOfShoot, View view)
    {
        _model = model;
        _view = view;
        _pointOfShoot = pointOfShoot;
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

        _view.SetAnimatorController(_noWeaponAnimator);
        EventManager.Trigger("ChangeEquipedWeapontUI", -1);
        EventManager.Trigger("ChangeBulletUI", 0, 0);
        Destroy(_actualWeapon.gameObject);
    }

    public void ChangeRenderer()
    { 
        Debug.Log("cambiando rendererer");
        foreach (var weaponStruct in _weaponsRenderer)
        {
            foreach (var render in weaponStruct._myRenders)
            {
                Debug.Log(render.name + " apagado");
                render.enabled = false;
            }
        }
        
        foreach (var item in _weaponsRenderer[_actualWeapon.GetID()]._myRenders)
        {
            Debug.Log(item.name + " prendido?");
            item.enabled = true;
        }
    }

    public void Interact(IAssistInteract usableItem = null)
    {
        EquipWeapon(usableItem.GetTransform().gameObject.GetComponent<GenericWeapon>(), true, true);
    }

    public Assistant.Interactuables GetType()
    {
        return Assistant.Interactuables.WEAPONMANAGER;
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

    public int InteractID()
    {
        return 0;
    }

    public bool isAutoUsable()
    {
        return false;
    }

    public Transform UsablePoint()
    {
        throw new NotImplementedException();
    }
}
