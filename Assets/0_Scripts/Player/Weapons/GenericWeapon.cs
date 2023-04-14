using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class GenericWeapon : MonoBehaviour
{
    [SerializeField] protected SO_Weapon _weaponSO;
    protected WeaponManager _weaponManager;

    [SerializeField] protected int _actualMagazineBullets;
    protected int _actualReserveBullets;

    //public RecoilSytem _recoilSystem;
    protected LayerMask _targetToShootMask;

    public abstract void Shoot(Transform pointOfShoot, bool isADS);
    public abstract void Reload();
    public abstract void FeedBack(Vector3 hitPoint, RaycastHit hit);

    protected ObjectPool _bulletPool;

    public void SetWeaponManager(WeaponManager weaponManager)
    {
        _weaponManager = weaponManager;
    }

    public bool CanShoot()
    {
        if (_weaponSO.isMelee) return true;
        else if (_actualMagazineBullets > 0) return true;
        else
        {
            //SoundManager.instance.PlaySound(SoundID.NO_AMMO);
            return false;
        }
    }

    public bool CanADS()
    {
        return _weaponSO.canADS;
    }

    public bool CanReload()
    {
        if (_actualReserveBullets <= 0 || _actualMagazineBullets >= _weaponSO.maxBulletsInMagazine)
            return false;
        else
            return true;
    }

    public bool CanBuyAmmo()
    {
        if (_actualReserveBullets < _weaponSO.maxBulletsInInventory && !_weaponSO.isMelee)
            return true;
        else
            return false;
    }

    public void OnWeaponEquip()
    {
        EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets);
        EventManager.Trigger("ChangeReserveBulletUI", _actualReserveBullets);
        EventManager.Trigger("ChangeEquipedWeapontUI", _weaponSO.weaponID);
    }

    public void OnWeaponUnequip()
    {
        //animator.SetTrigger("changeWeapon");

        EventManager.Trigger("OnADSDisable");

    }

    public bool GetTypeOfWeapons()
    {
        return _weaponSO.isMelee;
    }

    public int GetID()
    {
        return _weaponSO.weaponID;
    }

    public void PickUp()
    {
        gameObject.SetActive(true);
        EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets);
        EventManager.Trigger("ChangeReserveBulletUI", _actualReserveBullets);
        EventManager.Trigger("ChangeEquipedWeapontUI", _weaponSO.weaponID);
    }

    public void DropIt()
    {
        gameObject.SetActive(false);
    }


    public void AddBullets(int ammountToAddBullets)
    {
        int missingBullets = _weaponSO.maxBulletsInInventory - _actualReserveBullets;

        if (missingBullets < ammountToAddBullets)
        {
            _actualReserveBullets = _weaponSO.maxBulletsInInventory;
        }
        else
        {
            _actualReserveBullets += ammountToAddBullets;
        }

        if (isActiveAndEnabled)
        {
            EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets);
            EventManager.Trigger("ChangeReserveBulletUI", _actualReserveBullets);
        }
    }

    public GenericBullet GetBullet(Vector3 shootPoint)
    {
        return _bulletPool.GetObject(shootPoint).GetComponent<GenericBullet>();
    }

    public void ReturnBullet(GenericBullet bullet)
    {
        _bulletPool.ReturnObject(bullet.gameObject);
    }

    //CheatZone

    public void SetAmmo(int newAmmo)
    {
        _actualReserveBullets = newAmmo;

        EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets);
        EventManager.Trigger("ChangeReserveBulletUI", _actualReserveBullets);
    }
}
