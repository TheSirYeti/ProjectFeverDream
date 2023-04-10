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

    private void Start()
    {
        GenericWeapon[] equipedWeapons = transform.GetComponentsInChildren<GenericWeapon>();

        int actualIndex = 0;

        foreach (GenericWeapon weapon in equipedWeapons)
        {
            if (weapon.enabled) _actualWeapon = weapon;

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

    public void SetWeapon(GenericWeapon newWeapon)
    {
        _actualWeapon.OnWeaponUnequip();
        _actualWeapon = newWeapon;
        _actualWeapon.OnWeaponEquip();
    }

    public void DestroyWeapon()
    {
        Destroy(_actualWeapon.gameObject);
    }

    public void GoToNextWeapon(GenericWeapon brokenWeapon)
    {
        foreach (GenericWeapon weapon in _equipedWeapons)
        {
            if(weapon != brokenWeapon)
            {
                _actualWeapon = weapon;
                _actualWeapon.OnWeaponEquip();
                break;
            }
        }

        // Go to hands weapon
    }
}
