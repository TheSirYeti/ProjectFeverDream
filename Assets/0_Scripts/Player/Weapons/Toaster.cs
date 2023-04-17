using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Toaster : GenericWeapon
{
    [SerializeField] int numPellets = 10;
    [SerializeField] float spreadAngle = 20f;
    [SerializeField] float verticalAngle = 10f;

    [SerializeField] float _actualLoading = 0.3f;
    [SerializeField] float _loadSpeed = 0;

    /* -------------------------------- START -------------------------------- */
    void Start()
    {
        _actualReserveBullets = _weaponSO.initialBulletsInInventory;
        _actualMagazineBullets = _weaponSO.maxBulletsInMagazine;

        _bulletPool = new ObjectPool(_weaponSO._bulletPrefab, numPellets);

        EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets);
        EventManager.Trigger("ChangeReserveBulletUI", _actualReserveBullets);
    }

    private void Update()
    {
        OnUpdate();
    }


    /* -------------------------------- SHOOT -------------------------------- */
    public override void Shoot(Transform pointOfShoot, bool isADS)
    {
        if (_actualMagazineBullets <= 0) return;

        Vector3 actualDir = pointOfShoot.forward;

        int actualPellets = (int)(numPellets * _actualLoading);
        int actualDmg = (int)(_weaponSO.dmg * _actualLoading);

        for (int i = 0; i < actualPellets; i++)
        {
            float randomHorizontalAngle = Random.Range(-spreadAngle / 2f, spreadAngle / 2f);
            Quaternion horizontalRotation = Quaternion.AngleAxis(randomHorizontalAngle, Vector3.up);

            float randomVerticalAngle = Random.Range(-verticalAngle / 2f, verticalAngle / 2f);
            Quaternion verticalRotation = Quaternion.AngleAxis(randomVerticalAngle, actualDir);

            Quaternion pelletRotation = verticalRotation * horizontalRotation;

            Vector3 pelletDirection = pelletRotation * actualDir;

            GenericBullet bullet = GetBullet(pointOfShoot.position);
            bullet.OnStart(pelletDirection, this, actualDmg);
        }


        //SoundManager.instance.PlaySound(SoundID.PISTOL_SHOT);

        _actualMagazineBullets--;
        _actualLoading = 0.3f;

        EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets);
    }



    /* -------------------------------- FEEDBACK -------------------------------- */
    public override void FeedBack(Vector3 hitPoint, RaycastHit hit)
    {
        //_weaponSO.particleShoot.Play();

        //GameObject actualBullet = _bulletsPool.GetObject(_shootPoint.position);
        //LineRenderer lineRenderer = actualBullet.GetComponent<LineRenderer>();
        //lineRenderer.enabled = true;

        //StartCoroutine(TurnOffBullet(actualBullet));
        //StartCoroutine(TrailCoroutine(lineRenderer, hitPoint, hit));
    }



    /* -------------------------------- RELOAD -------------------------------- */
    public override void Reload()
    {
        int bulletsMissings = _weaponSO.maxBulletsInMagazine - _actualMagazineBullets;

        if (_actualReserveBullets >= bulletsMissings)
        {
            _actualMagazineBullets = _weaponSO.maxBulletsInMagazine;
            _actualReserveBullets -= bulletsMissings;
        }
        else
        {
            _actualMagazineBullets = _actualReserveBullets;
            _actualReserveBullets = 0;
        }

        EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets);
        EventManager.Trigger("ChangeReserveBulletUI", _actualReserveBullets);
    }

    public override void OnClick()
    {
        OnUpdate = LoadWeapon;
    }

    void LoadWeapon()
    {
        _actualLoading += _loadSpeed * Time.deltaTime;
        _actualLoading = Mathf.Clamp01(_actualLoading);
    }

    public override void OnRelease()
    {
        OnUpdate = delegate { };
    }
}
