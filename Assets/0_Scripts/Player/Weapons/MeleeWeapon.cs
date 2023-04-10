using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeleeWeapon : GenericWeapon
{
    [SerializeField] Collider _meleeCollider;
    [SerializeField] float _colliderDuration;

    [SerializeField] int _usageAmmount = 0;
    [SerializeField] bool _isBroken = false;

    [SerializeField] GenericWeapon brokenBagguete;

    List<ITakeDamage> _actualEnemiesHit = new List<ITakeDamage>();

    Coroutine _colliderCoroutine;

    private void Start()
    {
        _meleeCollider = GetComponent<BoxCollider>();
        _meleeCollider.enabled = false;

        //Cambiar speed animacion
    }

    public override void Shoot(Transform pointOfShoot, bool isADS)
    {
        _meleeCollider.enabled = true;

        if (_colliderCoroutine != null)
            StopCoroutine(_colliderCoroutine);

        _colliderCoroutine = StartCoroutine(HitCoroutine());
    }

    void CheckUsage()
    {
        if (_isBroken)
        {
            Debug.Log("Broken");
            if (_usageAmmount <= 0)
            {
                OnWeaponUnequip();
                _weaponManager.GoToNextWeapon(this);
                Destroy(gameObject);
            }
        }
        else
        {
            Debug.Log("Not broken");
            float actualPercent = _usageAmmount * 100 / 10;

            if (actualPercent > 75) return;
            else if (actualPercent > 50) EventManager.Trigger("OnBaguetteChangeState", 1);
            else if (actualPercent > 25) EventManager.Trigger("OnBaguetteChangeState", 2);
            else if (actualPercent > 0) EventManager.Trigger("OnBaguetteChangeState", 3);
            else if (actualPercent <= 0)
            {
                EventManager.Trigger("OnBaguetteChangeState", 4);
                brokenBagguete.gameObject.SetActive(true);
                _weaponManager.SetWeapon(brokenBagguete);
                gameObject.SetActive(false);
            }
        }
    }

    public override void FeedBack(Vector3 hitPoint, RaycastHit hit)
    {
        throw new System.NotImplementedException();
    }

    public override void Reload()
    {
        return;
    }

    public override void ReturnGameObject(GameObject item)
    {
        throw new System.NotImplementedException();
    }

    public override void SetGameObject(Vector3 objective)
    {
        throw new System.NotImplementedException();
    }

    IEnumerator HitCoroutine()
    {
        yield return new WaitForSeconds(_colliderDuration);
        _actualEnemiesHit = new List<ITakeDamage>();
        _meleeCollider.enabled = false;
    }

    private void OnTriggerEnter(Collider other)
    {
        ITakeDamage damagableInterface = other.GetComponentInParent<ITakeDamage>();

        if (damagableInterface != null && !_actualEnemiesHit.Contains(damagableInterface))
        {
            Debug.Log("Dmg");
            _actualEnemiesHit.Add(damagableInterface);
            damagableInterface.TakeDamage("Body", _weaponSO.dmg, true);

            _usageAmmount--;

            CheckUsage();
        }
    }
}
