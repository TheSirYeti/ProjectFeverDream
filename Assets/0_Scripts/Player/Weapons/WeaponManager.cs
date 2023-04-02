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
    bool _isShooting;

    public Action onUpdate = delegate { };

    public void OnStart(Model model, Transform pointOfShoot, View view)
    {
        _model = model;
        _view = view;
        _pointOfShoot = pointOfShoot;
    }

    private void Update()
    {
        onUpdate();
    }

    public void ChangeAttackState(bool state)
    {
        _isShooting = state;

        if (state)
            onUpdate += ShootAnimation;
    }

    public void ChangeADSState(bool state)
    {
        _isADS = state;
    }

    void ShootAnimation()
    {
        if (_isShooting)
            _view.SetTrigger("attack");
        else
        {
            _view.ResetTrigger("attack");
            onUpdate -= ShootAnimation;
        }
    }

    public void ExecuteShoot()
    {
        _actualWeapon.Shoot(_pointOfShoot, _isADS);
    }

    public void Reload()
    {
        if (_actualWeapon.CanReload())
            _actualWeapon.Reload();
    }

    public void ChangeWeapon(int newWeapon)
    {
        if (_equipedWeapons[newWeapon] == null) return;

        _actualWeapon.OnWeaponUnequip();
        _actualWeapon = _equipedWeapons[newWeapon];
        _actualWeapon.OnWeaponEquip();
    }
}
