using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using Random = UnityEngine.Random;

public class Toaster : GenericWeapon
{
    [SerializeField] private float _maxShootDistance;
    [SerializeField] private int numPellets = 10;
    [SerializeField] private float spreadAngle = 20f;
    [SerializeField] private float verticalAngle = 10f;

    [SerializeField] private float _actualLoading = 0.3f;
    [SerializeField] private float _loadSpeed = 0;
    [SerializeField] private Material burnToast, burnPieces;
    [SerializeField] private GameObject[] _decalPrefab;
    private ObjectPool _decalPool;

    private bool _particleIsActive = false;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
        _outline.enabled = false;
    }

    /* -------------------------------- START -------------------------------- */
    public override void OnStart()
    {
        _actualReserveBullets = _weaponSO.initialBulletsInInventory;
        _actualMagazineBullets = _weaponSO.maxBulletsInMagazine;

        _bulletPool = new ObjectPool(_weaponSO._bulletsPrefabs, numPellets);
        
        _maxActualBullets = _actualMagazineBullets;
    }

    public override void OnLateStart()
    {
        _weaponManager = GameManager.Instance.Player.weaponManager;
    }

    public override void OnUpdate()
    {
        OnDelegateUpdate();
        
        if (!_isEquiped) return;
        
        Debug.Log(_actualMagazineBullets + " | " + _maxActualBullets / 2);
        if (_actualMagazineBullets <= _maxActualBullets / 2)
        {
            EventManager.Trigger("LowAmmoEffect", true);
        }
        else
        {
            EventManager.Trigger("LowAmmoEffect", false);
        }
    }


    private List<Vector3> _dirsBullet = new List<Vector3>();
    private Vector3 _from;
    
    /* -------------------------------- SHOOT -------------------------------- */
    public override void Shoot(Transform pointOfShoot, bool isADS)
    {
        if (_actualMagazineBullets <= 0) return;

        var actualDir = Camera.main.transform.forward;

        if (_actualLoading < 0.5f) _actualLoading = 0.5f;

        var actualPellets = (int)(numPellets * _actualLoading);
        var actualDmg = (int)(_weaponSO.dmg * _actualLoading);
        var actualSpreadAngle = 1 - _actualLoading;
        if (actualSpreadAngle < 0.3f) actualSpreadAngle = 0.3f;

        var toasterHits = new Dictionary<Collider, int>();
        
        Debug.Log(actualPellets);
        _dirsBullet = new List<Vector3>();
        _from = pointOfShoot.position;

        for (var i = 0; i < actualPellets; i++)
        {
            var randomHorizontalAngle = Random.Range(-spreadAngle / 2f, spreadAngle / 2f);
            var horizontalRotation = Quaternion.AngleAxis(randomHorizontalAngle, Camera.main.transform.up);

            var randomVerticalAngle = Random.Range(-verticalAngle / 2f, verticalAngle / 2f);
            var verticalRotation = Quaternion.AngleAxis(randomVerticalAngle, Camera.main.transform.right);

            var pelletRotation = verticalRotation * horizontalRotation;

            var pelletDirection = pelletRotation * actualDir;
            
            _dirsBullet.Add(pelletDirection);

            if (!Physics.Raycast(pointOfShoot.position, pelletDirection, out var hit, _maxShootDistance,
                    LayerManager.LM_ENEMY) 
                || Physics.Raycast(pointOfShoot.position, pelletDirection, _maxShootDistance,
                    LayerManager.LM_ALLOBSTACLE)) continue;

            toasterHits.TryAdd(hit.collider, 0);
            toasterHits[hit.collider]++;
            Debug.Log(toasterHits[hit.collider]);

            var dir = hit.point - _nozzlePoint.position;

            var bullet = GetBullet(_nozzlePoint.position);
            bullet.BulletSetter(dir, this, actualDmg);
            StartCoroutine(DespawnBullet(bullet));
        }

        for (var i = 0; i < toasterHits.Count; i++)
        {
            var damageableObject = toasterHits.Select(x => x.Key).ToList();

            if (damageableObject.Any())
            {
                var distanceMultiplier =
                    1 - Vector3.Distance(transform.position, damageableObject[i].transform.position) /
                    _maxShootDistance;

                var actualEnemy = damageableObject[i].GetComponent<ITakeDamage>() ?? damageableObject[i].GetComponentInParent<ITakeDamage>();

                actualEnemy.TakeDamage("Body",
                    actualDmg * toasterHits[damageableObject[i]] * distanceMultiplier, transform.position,
                    Vector3.Distance(damageableObject[i].transform.position, transform.position) > 5
                        ? OnDeathKnockBacks.LIGHTKNOCKBACK
                        : OnDeathKnockBacks.HIGHKNOCKBACK);
            }
            else
            {
                // var decal = _decalPool.GetObject(toasterHits[i].point);
                // decal.transform.up = toasterHits[i].normal;
                // decal.transform.position += decal.transform.up * 0.2f;
                // StartCoroutine(DespawnCoroutine(decal));
            }
        }

        EventManager.Trigger("CameraShake", true);
        EventManager.Trigger("VFX_ToasterON", 1);
        //SoundManager.instance.PlaySound(SoundID.PISTOL_SHOT);

        _actualMagazineBullets--;
        _actualLoading = 0.3f;

        if (_actualMagazineBullets <= 0 && _actualReserveBullets > 0) _weaponManager.AnimReload();

        EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets, _weaponSO.maxBulletsInMagazine);

        if (_actualMagazineBullets<=0 && _actualReserveBullets <= 0)_weaponManager.DestroyWeapon();
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
            EventManager.Trigger("VFX_ToasterON", 0, 2, 3, 4);
            _particleIsActive = true;
        }
    }

    public override void OnRelease()
    {
        _weaponManager._view.SetBool(GetOnClickName(), false);
        OnDelegateUpdate = delegate { };
        EventManager.Trigger("VFX_ToasterOFF", 0, 2, 3, 4);
        _particleIsActive = false;
    }

    public override void CheckUsage()
    {
        return;
    }

    private IEnumerator DespawnCoroutine(GameObject actualDecal)
    {
        yield return new WaitForSeconds(2);
        _decalPool.ReturnObject(actualDecal);
    }

    private IEnumerator DespawnBullet(GenericBullet actualBullet)
    {
        yield return new WaitForSeconds(2);
        ReturnBullet(actualBullet);
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;

        if (_dirsBullet.Any())
        {
            foreach (var dir in _dirsBullet)
            {
                Gizmos.DrawLine(_from, _from+(dir * 5));
            }
        }
    }
}