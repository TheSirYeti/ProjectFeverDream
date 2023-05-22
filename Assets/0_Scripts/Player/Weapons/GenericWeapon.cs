using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public abstract class GenericWeapon : MonoBehaviour, IAssistPickUp, IInteractUI
{
    [SerializeField] protected SO_Weapon _weaponSO;
    protected WeaponManager _weaponManager;

    [SerializeField] protected int _actualMagazineBullets;
    protected int _actualReserveBullets;
    [SerializeField] protected int _maxUsageAmmount;
    [SerializeField] protected int usageAmmount = 0;

    [SerializeField] protected Transform _muzzle;

    [SerializeField] Rigidbody _rigidbody;
    [SerializeField] Collider _collider;

    protected Transform _nozzlePoint;
    [SerializeField] protected LayerMask _shooteableMask;

    [SerializeField] int _pickUpID;

    public abstract void Shoot(Transform pointOfShoot, bool isADS);
    public abstract void Reload();
    public abstract void FeedBack(Vector3 hitPoint, RaycastHit hit);
    public abstract void CheckUsage();

    public abstract void OnClick();
    public abstract void OnRelease();

    protected ObjectPool _bulletPool;

    protected Action OnUpdate = delegate { };

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

    public void OnWeaponEquip(Transform parent, WeaponManager weaponManager, Transform nozzlePoint)
    {
        _collider.enabled = false;
        _nozzlePoint = nozzlePoint;

        _weaponManager = weaponManager;

        _rigidbody.constraints = RigidbodyConstraints.FreezeAll;

        transform.position = parent.position;
        transform.rotation = parent.rotation;
        transform.parent = parent;

        CheckUsage();

        if (_weaponSO.isMelee)
        {
            EventManager.Trigger("ChangeBulletUI", usageAmmount, _maxUsageAmmount);
            EventManager.Trigger("ChangeReserveBulletUI", 0);
        }
        else
        {
            EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets, _weaponSO.maxBulletsInMagazine);
            EventManager.Trigger("ChangeReserveBulletUI", _actualReserveBullets);
        }
        EventManager.Trigger("ChangeEquipedWeapontUI", _weaponSO.weaponID);
    }

    public void OnWeaponUnequip()
    {
        //animator.SetTrigger("changeWeapon");
        transform.parent = null;

        _collider.enabled = true;

        _rigidbody.constraints = RigidbodyConstraints.None;

        EventManager.Trigger("OnADSDisable");

    }

    protected IEnumerator LateStart()
    {
        yield return new WaitForEndOfFrame();
        _weaponManager = GameManager.instace.Player.weaponManager;
    }

    #region SO Getters
    public bool GetTypeOfWeapons()
    {
        return _weaponSO.isMelee;
    }

    public int GetID()
    {
        return _weaponSO.weaponID;
    }

    public string GetOnClickName()
    {
        return _weaponSO.onClickAnimatorTrigger;
    }

    public string GetOnReleaseName()
    {
        return _weaponSO.onReleaseAnimatorTrigger;
    }

    public RuntimeAnimatorController GetAnimatorController()
    {
        return _weaponSO.animatorController;
    }
    #endregion

    #region Bullets Region
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
            EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets, _weaponSO.maxBulletsInMagazine);
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
    #endregion

    #region Usable Interface
    public void Use(IAssistUsable actionable)
    {
        throw new NotImplementedException();
    }

    public GameObject GetGameObject()
    {
        return gameObject;
    }

    public bool IsAutoUsable()
    {
        return true;
    }

    public Transform GetTarget()
    {
        return _weaponManager.transform;
    }

    public int InteractID()
    {
        return _pickUpID;
    }

    public string ActionName()
    {
        return "Pick up the weapon";
    }
    #endregion

    #region CheatZone
    public void SetAmmo(int newAmmo)
    {
        _actualReserveBullets = newAmmo;

        EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets, _weaponSO.maxBulletsInMagazine);
        EventManager.Trigger("ChangeReserveBulletUI", _actualReserveBullets);
    }
    #endregion
}
