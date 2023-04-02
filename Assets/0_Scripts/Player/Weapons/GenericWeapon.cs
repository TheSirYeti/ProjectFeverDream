using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class GenericWeapon : MonoBehaviour
{
    protected float _fireRate;
    [SerializeField] protected float _dmg;
    protected int _actualMagazineBullets;
    protected int _actualReserveBullets;
    [SerializeField] protected int _magazineBullets;
    [SerializeField] protected int _initialReserveBullets;
    [SerializeField] protected int _maxReserveBullets;
    [SerializeField] protected Transform _shootPoint;

    //public RecoilSytem _recoilSystem;
    public LayerMask _targetToShootMask;

    //[SerializeField] protected ObjectPool _bulletsPool;
    //[SerializeField] protected ObjectPool _wallDecalPool;
    //[SerializeField] protected ObjectPool _enemyDecalPool;
    //[SerializeField] protected ObjectPool _particleCollisionPool;
    [SerializeField] protected ParticleSystem _particleShoot;
    [SerializeField] protected GameObject lightMuzzle;

    [SerializeField] bool _canADS;
    [SerializeField] bool _isMelee;
    [SerializeField] int _idWeapon;


    public abstract void Shoot(Transform pointOfShoot, bool isADS);
    public abstract void Reload();
    public abstract void FeedBack(Vector3 hitPoint, RaycastHit hit);
    public abstract void SetGameObject(Vector3 objective);
    public abstract void ReturnGameObject(GameObject item);

    public bool CanShoot()
    {
        if (_isMelee) return true;
        else if (_actualMagazineBullets > 0) return true;
        else
        {
            //SoundManager.instance.PlaySound(SoundID.NO_AMMO);
            return false;
        }
    }

    public bool CanADS()
    {
        return _canADS;
    }

    public bool CanReload()
    {
        if (_actualReserveBullets <= 0 || _actualMagazineBullets >= _magazineBullets)
            return false;
        else
            return true;
    }

    public bool CanBuyAmmo()
    {
        if (_actualReserveBullets < _maxReserveBullets && !_isMelee)
            return true;
        else
            return false;
    }

    public void OnWeaponEquip()
    {
        EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets);
        EventManager.Trigger("ChangeReserveBulletUI", _actualReserveBullets);
        EventManager.Trigger("ChangeEquipedWeapontUI", _idWeapon);
    }

    public void OnWeaponUnequip()
    {
        //animator.SetTrigger("changeWeapon");

        EventManager.Trigger("OnADSDisable");

    }

    public bool GetTypeOfWeapons()
    {
        return _isMelee;
    }

    public int GetID()
    {
        return _idWeapon;
    }

    public void PickUp()
    {
        gameObject.SetActive(true);
        EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets);
        EventManager.Trigger("ChangeReserveBulletUI", _actualReserveBullets);
        EventManager.Trigger("ChangeEquipedWeapontUI", _idWeapon);
    }

    public void DropIt()
    {
        gameObject.SetActive(false);
    }


    public void AddBullets(int ammountToAddBullets)
    {
        int missingBullets = _maxReserveBullets - _actualReserveBullets;

        if (missingBullets < ammountToAddBullets)
        {
            _actualReserveBullets = _maxReserveBullets;
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

    //CheatZone

    public void SetAmmo(int newAmmo)
    {
        _actualReserveBullets = newAmmo;

        EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets);
        EventManager.Trigger("ChangeReserveBulletUI", _actualReserveBullets);
    }
}
