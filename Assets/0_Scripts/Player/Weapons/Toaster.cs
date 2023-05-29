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

    bool _particleIsActive = false;

    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    /* -------------------------------- START -------------------------------- */
    public override void OnStart()
    {
        _actualReserveBullets = _weaponSO.initialBulletsInInventory;
        _actualMagazineBullets = _weaponSO.maxBulletsInMagazine;

        _bulletPool = new ObjectPool(_weaponSO._bulletsPrefabs, numPellets * 3);

        //EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets, _weaponSO.maxBulletsInMagazine);
        //EventManager.Trigger("ChangeReserveBulletUI", _actualReserveBullets);

        StartCoroutine(LateStart());
    }

    public override void OnLateStart()
    {
        //TODO: Pasar los late start de las armas a cada una
    }

    public override void OnUpdate()
    {
        OnDelegateUpdate();
    }


    /* -------------------------------- SHOOT -------------------------------- */
    public override void Shoot(Transform pointOfShoot, bool isADS)
    {
        if (_actualMagazineBullets <= 0) return;

        Vector3 actualDir = pointOfShoot.forward;

        int actualPellets = (int)(numPellets * _actualLoading);
        int actualDmg = (int)(_weaponSO.dmg * _actualLoading);

        List<RaycastHit> toasterHits = new List<RaycastHit>();
        List<int> ammountPellets = new List<int>();

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
                if (!toasterHits.Contains(hit))
                {
                    toasterHits.Add(hit);
                    ammountPellets.Add(0);
                }

                ammountPellets[toasterHits.IndexOf(hit)]++;

                Vector3 dir = hit.point - _nozzlePoint.position;

                GenericBullet bullet = GetBullet(_nozzlePoint.position);
                bullet.BulletSetter(dir, this, actualDmg);
            }
        }

        for (int i = 0; i < toasterHits.Count; i++)
        {
            toasterHits[i].collider.GetComponentInParent<ITakeDamage>()?.TakeDamage("Body", actualDmg * ammountPellets[i]);
        }

        EventManager.Trigger("CameraShake", true);
        EventManager.Trigger("VFX_ToasterON", 1);
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
        //burnPieces.SetFloat("_BurnValue", 0);
        OnDelegateUpdate = LoadWeapon;
    }

    void LoadWeapon()
    {
        _actualLoading += _loadSpeed * Time.deltaTime;
        burnToast.SetFloat("_BurnValue", _actualLoading);
        //burnPieces.SetFloat("_BurnValue", _actualLoading);
        _actualLoading = Mathf.Clamp01(_actualLoading);

        if (!_particleIsActive && _actualLoading > 0.2f)
        {
            EventManager.Trigger("VFX_ToasterON", 0);
            _particleIsActive = true;
        }
    }

    public override void OnRelease()
    {
        _weaponManager._view.SetBool(GetOnClickName(), false);
        OnDelegateUpdate = delegate { };
        EventManager.Trigger("VFX_ToasterOFF", 0);
        _particleIsActive = false;
    }

    public override void CheckUsage()
    {
        return;
    }
}