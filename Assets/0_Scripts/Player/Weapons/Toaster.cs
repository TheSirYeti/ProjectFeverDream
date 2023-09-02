using System.Collections;
using System.Collections.Generic;
using UnityEngine;

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
    }

    /* -------------------------------- START -------------------------------- */
    public override void OnStart()
    {
        _actualReserveBullets = _weaponSO.initialBulletsInInventory;
        _actualMagazineBullets = _weaponSO.maxBulletsInMagazine;

        _bulletPool = new ObjectPool(_weaponSO._bulletsPrefabs, numPellets * 3);
        _decalPool = new ObjectPool(_decalPrefab, numPellets * 2);

        //EventManager.Trigger("ChangeBulletUI", _actualMagazineBullets, _weaponSO.maxBulletsInMagazine);
        //EventManager.Trigger("ChangeReserveBulletUI", _actualReserveBullets);
    }

    public override void OnLateStart()
    {
        _weaponManager = GameManager.Instance.Player.weaponManager;
    }

    public override void OnUpdate()
    {
        OnDelegateUpdate();
    }


    /* -------------------------------- SHOOT -------------------------------- */
    public override void Shoot(Transform pointOfShoot, bool isADS)
    {
        if (_actualMagazineBullets <= 0) return;

        var actualDir = pointOfShoot.forward;

        var actualPellets = (int)(numPellets * _actualLoading);
        var actualDmg = (int)(_weaponSO.dmg * _actualLoading);
        var actualSpreadAngle = 1 - _actualLoading;
        if (actualSpreadAngle < 0.3f) actualSpreadAngle = 0.3f;

        List<RaycastHit> toasterHits = new List<RaycastHit>();
        List<int> ammountPellets = new List<int>();

        for (int i = 0; i < actualPellets; i++)
        {
            var randomHorizontalAngle = Random.Range(-spreadAngle / 2f, spreadAngle / 2f);
            var horizontalRotation = Quaternion.AngleAxis(randomHorizontalAngle * actualSpreadAngle, Vector3.up);

            var randomVerticalAngle = Random.Range(-verticalAngle / 2f, verticalAngle / 2f);
            var verticalRotation = Quaternion.AngleAxis(randomVerticalAngle, pointOfShoot.right);

            var pelletRotation = verticalRotation * horizontalRotation;

            var pelletDirection = pelletRotation * actualDir;

            RaycastHit hit;
            if (Physics.Raycast(pointOfShoot.position, pelletDirection, out hit, _maxShootDistance, LayerManager.LM_WEAPONSTARGETS))
            {
                if (!toasterHits.Contains(hit))
                {
                    toasterHits.Add(hit);
                    ammountPellets.Add(0);
                }

                ammountPellets[toasterHits.IndexOf(hit)]++;

                var dir = hit.point - _nozzlePoint.position;

                var bullet = GetBullet(_nozzlePoint.position);
                bullet.BulletSetter(dir, this, actualDmg);
                StartCoroutine(DespawnBullet(bullet));
            }
        }

        for (var i = 0; i < toasterHits.Count; i++)
        {
            var damagableObject = toasterHits[i].collider.GetComponentInParent<ITakeDamage>();

            if (damagableObject != null)
            {
                var distanceMultiplier = 1 - (Vector3.Distance(transform.position, toasterHits[i].point) / _maxShootDistance);                                             
                damagableObject?.                                                                                                                                          
                    TakeDamage("Body", actualDmg * ammountPellets[i] * distanceMultiplier, transform.position,                                                             
                        Vector3.Distance(toasterHits[i].point, transform.position) > 5 ? OnDeathKnockBacks.LIGHTKNOCKBACK : OnDeathKnockBacks.HIGHKNOCKBACK);              
            }
            else
            {
                var decal = _decalPool.GetObject(toasterHits[i].point);
                decal.transform.up = toasterHits[i].normal;
                decal.transform.position += decal.transform.up * 0.2f;
                StartCoroutine(DespawnCoroutine(decal));
            }
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
}