using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class GenericBullet : GenericObject
{
    [SerializeField] protected float _timerToBack;
    protected float _time;
    [SerializeField] protected float _speed;
    [SerializeField] float _distanceCollision;
    protected float _dmg;
    [SerializeField] LayerMask _collisionMask;
    [SerializeField] protected LayerMask _damagableMask;

    [Header("THIS IS A TEMP GAMEOBJECT, CHANGE LATER")] [SerializeField]
    protected GameObject _fakeDecal;

    protected GenericWeapon _actualWeapon;
    [SerializeField] protected bool _canDmg;

    private void OnDisable()
    {
        StopAllCoroutines();
        UpdateManager._instance.RemoveObject(this);
    }

    public void BulletSetter(Vector3 dir, GenericWeapon actualWeapon, float dmg)
    {
        UpdateManager._instance.AddObject(this);
        
        transform.forward = dir;
        _actualWeapon = actualWeapon;
        _dmg = dmg;
    }

    protected void Movement()
    {
        transform.position += transform.forward * (_speed * Time.deltaTime);
        CheckCollisions();
    }

    void CheckCollisions()
    {
        RaycastHit hit;
        if (Physics.Raycast(transform.position, transform.forward, out hit, _distanceCollision, _damagableMask))
        {
            if (_canDmg)
                hit.collider.GetComponentInParent<ITakeDamage>().TakeDamage("Body", _dmg);

            _actualWeapon.ReturnBullet(this);
        }
        else if (Physics.Raycast(transform.position, transform.forward, out hit, _distanceCollision, _collisionMask))
        {
            GameObject decal = Instantiate(_fakeDecal, hit.point, transform.rotation);
            decal.transform.forward = hit.normal * -1;
            Destroy(decal, 3f);
            _actualWeapon.ReturnBullet(this);
        }
    }
}