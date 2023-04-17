using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class WeaponManager : MonoBehaviour
{
    Model _model;
    View _view;

    [SerializeField] GenericWeapon _actualWeapon;
    [SerializeField] GenericWeapon[] _equipedWeapons = new GenericWeapon[3];

    Transform _pointOfShoot;
    bool _isADS;

    public Action OnClick = delegate { };
    public Action OnRelease = delegate { };


    private void Start()
    {
        GenericWeapon[] equipedWeapons = transform.GetComponentsInChildren<GenericWeapon>();

        int actualIndex = 0;

        foreach (GenericWeapon weapon in equipedWeapons)
        {
            weapon.gameObject.SetActive(false);

            if (actualIndex == 0) 
            { 
                _actualWeapon = weapon;
                OnClick = _actualWeapon.OnClick;
                OnRelease = _actualWeapon.OnRelease;
                _actualWeapon.gameObject.SetActive(true);
                _view.SetAnimatorController(_actualWeapon.GetAnimatorController());
            }

            _equipedWeapons[actualIndex] = weapon;
            weapon.SetWeaponManager(this);
            actualIndex++;
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
        if (state)
        {
            _view.SetBool(_actualWeapon.GetOnClickName(), true);
            OnClick();
        }
        else
        {
            _view.SetBool(_actualWeapon.GetOnClickName(), false);
            OnRelease();

            if (_actualWeapon.GetOnReleaseName() != "")
                _view.SetTrigger(_actualWeapon.GetOnReleaseName());
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
        if (_actualWeapon.CanReload())
            _view.SetTrigger("reload");
    }

    public void ExecuteReload()
    {
        _actualWeapon.Reload();
    }

    public void ChangeWeapon(int newWeapon)
    {
        if (_equipedWeapons[newWeapon] == null) return;

        _actualWeapon.OnWeaponUnequip();
        _actualWeapon = _equipedWeapons[newWeapon];
        _actualWeapon.OnWeaponEquip();

        _view.SetAnimatorController(_actualWeapon.GetAnimatorController());
        OnClick = _actualWeapon.OnClick;
        OnRelease = _actualWeapon.OnRelease;
    }

    public void SetWeapon(GenericWeapon newWeapon)
    {
        _actualWeapon.OnWeaponUnequip();
        _actualWeapon = newWeapon;
        _actualWeapon.OnWeaponEquip();

        _view.SetAnimatorController(_actualWeapon.GetAnimatorController());
        OnClick = _actualWeapon.OnClick;
        OnRelease = _actualWeapon.OnRelease;
    }

    public void DestroyWeapon()
    {
        Destroy(_actualWeapon.gameObject);
    }

    public void GoToNextWeapon(GenericWeapon brokenWeapon)
    {
        foreach (GenericWeapon weapon in _equipedWeapons)
        {
            if (weapon != brokenWeapon)
            {
                _actualWeapon = weapon;
                _actualWeapon.OnWeaponEquip();
                break;
            }
        }

        // Go to hands weapon
    }
}
