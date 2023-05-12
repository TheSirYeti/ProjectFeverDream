using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RangedBullet : MonoBehaviour
{
    [SerializeField] private float bulletSpeed;
    [SerializeField] private float timeToDie;

    private void Start()
    {
        Destroy(gameObject, timeToDie);
    }

    private void Update()
    {
        transform.position += transform.forward * bulletSpeed * Time.fixedDeltaTime;
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.layer == LayerMask.NameToLayer("Wall") ||
            other.gameObject.layer == LayerMask.NameToLayer("Floor") ||
            other.gameObject.layer == LayerMask.NameToLayer("Player"))
        {
            Destroy(gameObject);
        }
    }
}
