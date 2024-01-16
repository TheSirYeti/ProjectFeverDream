using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UtensilDrop : GenericObject
{
    [SerializeField] private ParticleSystem _impactParticles;
    [Space(10)]
    [SerializeField] private Transform _centerOfImpact;
    [SerializeField] private float _raycastOffset;
    [SerializeField] private float _downwardSpeed;
    [Space(10)] 
    [SerializeField] private int _totalDamage;
    [Space(10)]
    [SerializeField] private float _timeToDie;

    private bool hasCollided = false;
    private float currentTimer = 0f;
    private float expirationTimer = 10f;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnStart()
    {
        StartCoroutine(DropUtensil());
    }

    IEnumerator DropUtensil()
    {
        while (!Physics.Raycast(_centerOfImpact.position,
                   Vector3.down,
                   _raycastOffset,
                   LayerManager.LM_FLOOR) 
               && currentTimer < expirationTimer)
        {
            currentTimer += Time.deltaTime;
            transform.position += _downwardSpeed * Vector3.down * Time.deltaTime;
            yield return new WaitForSeconds(Time.deltaTime);
        }

        hasCollided = true;
        if (_impactParticles != null)
        {
            _impactParticles.Play();
        }

        yield return new WaitForSeconds(_timeToDie);
        Destroy(gameObject);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.TryGetComponent<IPlayerLife>(out IPlayerLife player) && !hasCollided)
        {
           player.GetDamage(_totalDamage);
           Destroy(gameObject);
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawLine(_centerOfImpact.position, _centerOfImpact.position + new Vector3(0, _raycastOffset, 0));
    }
}
