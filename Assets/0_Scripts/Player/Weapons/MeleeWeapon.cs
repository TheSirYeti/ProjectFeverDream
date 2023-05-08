using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class MeleeWeapon : GenericWeapon
{
    [SerializeField] Collider _meleeCollider;
    [SerializeField] float _colliderDuration;


    [SerializeField] bool _isBroken = false;

    [SerializeField] GameObject brokenBagguete;

    [SerializeField] int _maxCombo;
    [SerializeField] float _comboDuration;
    int _actualAttack = 0;
    float _holdTimer = 0;
    [SerializeField] float _holdSpeed;

    List<ITakeDamage> _actualEnemiesHit = new List<ITakeDamage>();

    Coroutine _colliderCoroutine;
    Coroutine _comboCoroutine;

    private void Start()
    {
        _meleeCollider = GetComponent<BoxCollider>();
        _meleeCollider.enabled = false;

        //Get shootpoint

        //Cambiar speed animacion
    }

    private void Update()
    {
        OnUpdate();
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

        if (_isBroken)
        {
            if (usageAmmount <= 0)
            {
                _weaponManager.DestroyWeapon();
            }
        }
        else
        {
            float actualPercent = usageAmmount * 100 / 10;

            if (actualPercent > 75) return;
            else if (actualPercent > 50) EventManager.Trigger("OnBaguetteChangeState", 1);
            else if (actualPercent > 25) EventManager.Trigger("OnBaguetteChangeState", 2);
            else if (actualPercent > 0) EventManager.Trigger("OnBaguetteChangeState", 3);
            else if (actualPercent <= 0)
            {
                EventManager.Trigger("OnBaguetteChangeState", 4);
                GameObject broken = Instantiate(brokenBagguete, transform.parent);

                _weaponManager.SetWeapon(broken.GetComponent<GenericWeapon>(), false);
                Destroy(gameObject);
            }
        }
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
        ITakeDamage damagableInterface = other.GetComponentInParent<ITakeDamage>();

        if (damagableInterface != null && !_actualEnemiesHit.Contains(damagableInterface))
        {
            if (!damagableInterface.IsAlive())
                return;

            EventManager.Trigger("CameraShake", true);

            if (!_actualEnemiesHit.Any())
            {
                usageAmmount--;

                usageAmmount = Mathf.Clamp(usageAmmount, 0, _maxUsageAmmount);

                CheckUsage();
            }

            _actualEnemiesHit.Add(damagableInterface);
            damagableInterface.TakeDamage("Body", _weaponSO.dmg, true);
        }
    }

    //solucionar despues
    public override void OnClick()
    {
        _weaponManager._view.SetInt("actualAttack", _actualAttack);
        _weaponManager._view.SetTrigger(GetOnClickName());
        _holdTimer = 0;
        OnUpdate = OnHold;
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
        OnUpdate = delegate { };
    }
}
