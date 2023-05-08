using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class WeaponManager : MonoBehaviour, IAttendance
{
    Model _model;
    [HideInInspector] public View _view;
    [SerializeField] RuntimeAnimatorController _noWeaponAnimator;

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

    public Action OnClick = delegate { };
    public Action OnRelease = delegate { };


    private void Start()
    {
        if (_actualWeapon)
        {
            foreach (Renderer item in _weaponsRenderer[_actualWeapon.GetID()]._myRenders)
            {
                item.enabled = true;
            }

            _actualWeapon.OnWeaponEquip(transform, this, _nozzlePoint);

            OnClick = _actualWeapon.OnClick;
            OnRelease = _actualWeapon.OnRelease;
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

    public void SetWeapon(GenericWeapon newWeapon, bool turnOffPrevious = true)
    {
        if (_actualWeapon != null && turnOffPrevious)
        {
            _actualWeapon.OnWeaponUnequip();

            //foreach (Renderer item in _weaponsRenderer[_actualWeapon.GetID()]._myRenders)
            //{
            //    item.enabled = false;
            //}
        }

        foreach (WeaponRenderer weaponStruct in _weaponsRenderer)
        {
            foreach (Renderer render in weaponStruct._myRenders)
            {
                render.enabled = false;
            }
        }


        _actualWeapon = newWeapon;
        _actualWeapon.OnWeaponEquip(transform, this, _nozzlePoint);

        foreach (Renderer item in _weaponsRenderer[_actualWeapon.GetID()]._myRenders)
        {
            item.enabled = true;
        }

        _view.SetAnimatorController(_actualWeapon.GetAnimatorController());
        OnClick = _actualWeapon.OnClick;
        OnRelease = _actualWeapon.OnRelease;
    }

    public void DestroyWeapon()
    {
        OnClick = delegate { };
        OnRelease = delegate { };

        foreach (Renderer item in _weaponsRenderer[_actualWeapon.GetID()]._myRenders)
        {
            item.enabled = false;
        }

        _view.SetAnimatorController(_noWeaponAnimator);
        EventManager.Trigger("ChangeEquipedWeapontUI", -1);
        EventManager.Trigger("ChangeBulletUI", 0, 0);
        Destroy(_actualWeapon.gameObject);
    }

    public void Interact(GameObject usableItem = null)
    {
        if (!usableItem) return;

        GenericWeapon weapon = usableItem.GetComponent<GenericWeapon>();

        SetWeapon(weapon);
    }

    Assistant.Interactuables IAttendance.GetType()
    {
        return Assistant.Interactuables.WEAPONMANAGER;
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
        return null;
    }

    public bool CanInteract()
    {
        return true;
    }

    public string AnimationToExecute()
    {
        return "GiveWeapon";
    }
}
