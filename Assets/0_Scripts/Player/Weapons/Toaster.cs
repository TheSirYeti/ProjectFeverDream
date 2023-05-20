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
    [SerializeField] private Material burnToast, burnPieces;


    [SerializeField] protected ParticleSystem _loadingShootParticle;

    /* -------------------------------- START -------------------------------- */
    void Start()
    {
        _actualReserveBullets = _weaponSO.initialBulletsInInventory;
        _actualMagazineBullets = _weaponSO.maxBulletsInMagazine;

        _bulletPool = new ObjectPool(_weaponSO._bulletsPrefabs, numPellets * 3);

        //EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets, _weaponSO.maxBulletsInMagazine);
        //EventManager.Trigger("ChangeReserveBulletUI", _actualReserveBullets);

        StartCoroutine(LateStart());
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

            RaycastHit hit;
            if (Physics.Raycast(pointOfShoot.position, pelletDirection, out hit, Mathf.Infinity, _shooteableMask))
            {
                Vector3 dir = hit.point - _nozzlePoint.position;
                
                GenericBullet bullet = GetBullet(_nozzlePoint.position);
                bullet.OnStart(dir, this, actualDmg);
            }
        }

        EventManager.Trigger("CameraShake", true);
        //SoundManager.instance.PlaySound(SoundID.PISTOL_SHOT);

        _actualMagazineBullets--;
        _actualLoading = 0.3f;

        if (_actualMagazineBullets <= 0) _weaponManager.AnimReload();

        EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets, _weaponSO.maxBulletsInMagazine);
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
        burnToast.SetFloat("_BurnValue", 0);
        burnPieces.SetFloat("_BurnValue", 0);
        
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

        EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets, _weaponSO.maxBulletsInMagazine);
        EventManager.Trigger("ChangeReserveBulletUI", _actualReserveBullets);
    }

    public override void OnClick()
    {
        _weaponManager._view.SetBool(GetOnClickName(), true);
        burnToast.SetFloat("_BurnValue", 0);
        burnPieces.SetFloat("_BurnValue", 0);
        OnUpdate = LoadWeapon;
    }

    void LoadWeapon()
    {
        _loadingShootParticle.gameObject.transform.position = _nozzlePoint.position;

        _actualLoading += _loadSpeed * Time.deltaTime;
        burnToast.SetFloat("_BurnValue", _actualLoading);
        burnPieces.SetFloat("_BurnValue", _actualLoading);
        _actualLoading = Mathf.Clamp01(_actualLoading);

        if (!_loadingShootParticle.isPlaying && _actualLoading >= 1)
            _loadingShootParticle.Play();
    }

    public override void OnRelease()
    {
        _weaponManager._view.SetBool(GetOnClickName(), false);
        OnUpdate = delegate { };
        _loadingShootParticle.Stop();
    }

    public override void CheckUsage()
    {
        return;
    }
}
