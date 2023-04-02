using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MeleeWeapon : GenericWeapon
{
    [SerializeField] Collider _meleeCollider;
    [SerializeField] float _colliderDuration;

    Coroutine _colliderCoroutine;

    public override void Shoot(Transform pointOfShoot, bool isADS)
    {
        _meleeCollider.enabled = true;

        if (_colliderCoroutine != null)
            StopCoroutine(_colliderCoroutine);

        _colliderCoroutine = StartCoroutine(HitCoroutine());
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
        _meleeCollider.enabled = false;
    }

    private void OnTriggerEnter(Collider other)
    {
        ITakeDamage damagableInterface = other.GetComponentInParent<ITakeDamage>();

        if (damagableInterface != null)
            damagableInterface.TakeDamage("Body", _dmg, true);
    }
}
