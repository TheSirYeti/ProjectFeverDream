using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public abstract class GenericWeapon : GenericObject, IAssistInteract, IPickUp
{
    [SerializeField] protected SO_Weapon _weaponSO;
    protected WeaponManager _weaponManager;
    private Model _player => GameManager.Instance.Player;

    [SerializeField] protected int _actualMagazineBullets;
    protected int _maxActualBullets;
    protected int _actualReserveBullets;
    [SerializeField] protected int _maxUsageAmmount;
    [SerializeField] protected int usageAmmount = 0;

    [SerializeField] protected Transform _muzzle;

    [SerializeField] Rigidbody _rigidbody;
    [SerializeField] Collider _collider;

    protected Transform _nozzlePoint;

    [SerializeField] protected Outline _outline;
    public bool _isEquiped = false;

    public bool _isHandWeapon = false;

    public abstract void Shoot(Transform pointOfShoot, bool isADS);
    public abstract void Reload();
    public abstract void FeedBack(Vector3 hitPoint, RaycastHit hit);
    public abstract void CheckUsage();

    public abstract void OnClick();
    public abstract void OnRelease();

    protected ObjectPool _bulletPool;

    protected Action OnDelegateUpdate = delegate { };

    public bool CanShoot()
    {
        if (_weaponSO.isMelee || _actualMagazineBullets > 0) return true;

        return false;
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
        _isEquiped = true;
        _nozzlePoint = nozzlePoint;

        _weaponManager = weaponManager;

        ChangeCollisions(false);

        transform.position = parent.position - parent.up;
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
        OnDelegateUpdate = delegate { };

        if (!_isHandWeapon)
        {
            transform.parent = null;
            transform.position = _player.transform.position + (_player.transform.forward * 1);

            ChangeCollisions(true);

            _rigidbody.AddForce((_player.transform.forward * 100) + (Vector3.up * 5));
        }
        
        _isEquiped = false;

        EventManager.Trigger("OnADSDisable");
    }

    public void ChangeCollisions(bool state)
    {
        if (_isHandWeapon) return;
        
        if (state)
        {
            _collider.enabled = true;

            _rigidbody.constraints = RigidbodyConstraints.None;
            _rigidbody.useGravity = true;
            _rigidbody.isKinematic = false;
        }
        else
        {
            _collider.enabled = false;

            _rigidbody.constraints = RigidbodyConstraints.FreezeAll;
            _rigidbody.useGravity = false;
            _rigidbody.isKinematic = true;
        }
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

    //TODO: Set Interfaces

    public void ChangeOutlineState(bool state)
    {
        _outline.enabled = state;
        _outline.OutlineWidth = 8;
    }

    public bool CanInteractWith(IAssistInteract assistInteract)
    {
        throw new NotImplementedException();
    }

    public bool IsAutoUsable()
    {
        return true;
    }

    public Transform GoesToUsablePoint()
    {
        return _weaponManager.transform;
    }

    public void Interact(IAssistInteract usableItem = null)
    {
    }

    public Interactuables GetInteractType()
    {
        return Interactuables.WEAPON;
    }

    public Assistant.JorgeStates GetState()
    {
        return Assistant.JorgeStates.PICKUP;
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
        return !_isEquiped;
    }

    public string ActionName()
    {
        return "Pick up the weapon";
    }

    public string AnimationToExecute()
    {
        throw new NotImplementedException();
    }

    #endregion

    #region PickUp Interface

    public void Pickup()
    {
        _isEquiped = true;
        ChangeCollisions(false);
    }

    public void UnPickUp()
    {
        transform.parent = null;
        _isEquiped = false;
        ChangeCollisions(true);
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