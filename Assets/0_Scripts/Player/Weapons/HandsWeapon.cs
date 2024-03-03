using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class HandsWeapon : GenericWeapon
{
    [SerializeField] Collider _meleeCollider;
    [SerializeField] float _colliderDuration;
    
    [SerializeField] int _maxCombo;
    [SerializeField] float _comboDuration;
    int _actualAttack = 0;
    float _holdTimer = 0;
    [SerializeField] float _holdSpeed;

    List<ITakeDamage> _actualEnemiesHit = new List<ITakeDamage>();

    Coroutine _colliderCoroutine;
    Coroutine _comboCoroutine;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnStart()
    {
        _meleeCollider = GetComponent<BoxCollider>();
        _meleeCollider.enabled = false;
    }

    public override void OnLateStart()
    {
        _weaponManager = GameManager.Instance.Player.weaponManager;
    }

    public override void OnUpdate()
    {
        OnDelegateUpdate();
    }

    private void OnDestroy()
    {
        StopAllCoroutines();
        UpdateManager.instance.RemoveObject(this);
    }

    public override void Shoot(Transform pointOfShoot, bool isADS)
    {
        _actualAttack++;

        if (_actualAttack > _maxCombo - 1)
            _actualAttack = 0;

        _meleeCollider.enabled = true;

        if (_colliderCoroutine != null)
            StopCoroutine(_colliderCoroutine);

        _colliderCoroutine = StartCoroutine(HitCoroutine());

        if (_comboCoroutine != null)
            StopCoroutine(_comboCoroutine);

        _comboCoroutine = StartCoroutine(ComboCoroutine());
    }

    public override void CheckUsage()
    {
        EventManager.Trigger("ChangeBulletUI", usageAmmount, _maxUsageAmmount);

        //Hands sound
    }

    public override void FeedBack(Vector3 hitPoint, RaycastHit hit)
    {
        return;
    }

    public override void Reload()
    {
        return;
    }

    IEnumerator HitCoroutine()
    {
        yield return new WaitForSeconds(_colliderDuration);
        _actualEnemiesHit = new List<ITakeDamage>();
        _meleeCollider.enabled = false;
    }

    IEnumerator ComboCoroutine()
    {
        yield return new WaitForSeconds(_comboDuration);
        _actualAttack = 0;
    }

    private void OnTriggerEnter(Collider other)
    {
        var damagableInterface = other.GetComponentInParent<ITakeDamage>();

        if (damagableInterface == null || _actualEnemiesHit.Contains(damagableInterface)) return;
        
        if (!damagableInterface.IsAlive())
            return;

        EventManager.Trigger("CameraShake", true);

        damagableInterface.TakeDamage("Body", _weaponSO.dmg, transform.position, OnDeathKnockBacks.LIGHTKNOCKBACK, _weaponSO.hasKnockback);

        if (_actualEnemiesHit.Any()) return;

        _actualEnemiesHit.Add(damagableInterface);

        CheckUsage();
    }

    public override void OnClick()
    {
        _weaponManager._view.SetInt("actualAttack", _actualAttack);
        _weaponManager._view.SetTrigger(GetOnClickName());
        _holdTimer = 0;
        OnDelegateUpdate = OnHold;
    }

    void OnHold()
    {
        _holdTimer += Time.deltaTime * _holdSpeed;

        if (_holdTimer > 1)
        {
            _weaponManager._view.SetTrigger(GetOnClickName());
        }
    }

    public override void OnRelease()
    {
        if (_holdTimer > 1)
            _weaponManager._view.ResetTrigger(GetOnClickName());

        _holdTimer = 0;
        OnDelegateUpdate = delegate { };
    }
}
