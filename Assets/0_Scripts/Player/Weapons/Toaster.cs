using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Toaster : GenericWeapon
{
    bool _isEnemy = false;
    [SerializeField] float randomHipRecoilX;
    [SerializeField] float randomHipRecoilY;

    [SerializeField] int numPellets = 10;
    [SerializeField] float spreadAngle = 20f;
    [SerializeField] float verticalAngle = 10f;


    /* -------------------------------- START -------------------------------- */
    void Start()
    {
        _actualReserveBullets = _weaponSO.initialBulletsInInventory;
        _actualMagazineBullets = _weaponSO.maxBulletsInMagazine;

        _bulletPool = new ObjectPool(_weaponSO._bulletPrefab, numPellets);

        EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets);
        EventManager.Trigger("ChangeReserveBulletUI", _actualReserveBullets);
    }


    /* -------------------------------- SHOOT -------------------------------- */
    public override void Shoot(Transform pointOfShoot, bool isADS)
    {
        if (_actualMagazineBullets <= 0) return;

        Vector3 actualDir = pointOfShoot.forward;

        for (int i = 0; i < numPellets; i++)
        {
            float randomHorizontalAngle = Random.Range(-spreadAngle / 2f, spreadAngle / 2f);
            Quaternion horizontalRotation = Quaternion.AngleAxis(randomHorizontalAngle, Vector3.up);

            float randomVerticalAngle = Random.Range(-verticalAngle / 2f, verticalAngle / 2f);
            Quaternion verticalRotation = Quaternion.AngleAxis(randomVerticalAngle, actualDir);

            Quaternion pelletRotation = verticalRotation * horizontalRotation;

            Vector3 pelletDirection = pelletRotation * actualDir;

            GenericBullet bullet = GetBullet(pointOfShoot.position);
            bullet.OnStart(pelletDirection, this, _weaponSO.dmg);
            // Instantiate or shoot the pellet in the pelletDirection
        }


        //SoundManager.instance.PlaySound(SoundID.PISTOL_SHOT);

        _actualMagazineBullets--;


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



    /* -------------------------------- OBJECTPOOL -------------------------------- */
    public void SetGameObject(Vector3 objective)
    {
        throw new System.NotImplementedException();
    }

    public void ReturnGameObject(GameObject item)
    {
        throw new System.NotImplementedException();
    }
}
