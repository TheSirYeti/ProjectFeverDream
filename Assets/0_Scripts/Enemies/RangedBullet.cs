using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class RangedBullet : MonoBehaviour
{
    [SerializeField] private float bulletSpeed;
    [SerializeField] private float timeToDie;
    [SerializeField] private List<GameObject> viewObjects;
    private int rand = 0;

    private void Start()
    {
        rand = Random.Range(0, viewObjects.Count);
        viewObjects[rand].SetActive(true);
        StartCoroutine(DoSignRotation());
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
    
    IEnumerator DoSignRotation()
    {
        while (true)
        {
            LeanTween.rotateX(viewObjects[rand], 180f, 0.1f);
            yield return new WaitForSeconds(0.1f);
            LeanTween.rotateX(viewObjects[rand], 360f, 0.1f);
            yield return new WaitForSeconds(0.1f);
        }
    }
}
