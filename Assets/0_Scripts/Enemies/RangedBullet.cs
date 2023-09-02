using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class RangedBullet : GenericObject
{
    [SerializeField] private float bulletSpeed;
    [SerializeField] private float timeToDie;
    [SerializeField] private float rotateSpeed;
    public float bulletDmg;
    [SerializeField] private List<GameObject> viewObjects;
    private int rand = 0;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
        
        rand = Random.Range(0, viewObjects.Count);
        viewObjects[rand].SetActive(true);
        StartCoroutine(DoSignRotation());
        StartCoroutine(DoDeath());
    }

    public override void OnStart()
    {
        
    }

    public override void OnUpdate()
    {
        transform.position += transform.forward * bulletSpeed * Time.fixedDeltaTime;
    }

    /*public void OnBulletSpawn()
    {
        UpdateManager._instance.AddObject(this);
    }*/

    private void OnDestroy()
    {
        StopAllCoroutines();
        UpdateManager.instance.RemoveObject(this);
    }

    private void OnTriggerEnter(Collider other)
    {
        IPlayerLife playerLife = other.GetComponentInParent<IPlayerLife>();
        //IReciveDamage damagable = other.GetComponent<IReciveDamage>();

        if (playerLife != null)
        {
            playerLife.GetDamage((int)bulletDmg);
        }
        
        if (other.gameObject.layer == LayerMask.NameToLayer("Wall") ||
            other.gameObject.layer == LayerMask.NameToLayer("Floor") ||
            other.gameObject.layer == LayerMask.NameToLayer("Player"))
        {
            StopCoroutine(DoDeath());
            UpdateManager.instance.RemoveObject(this);
            gameObject.SetActive(false);
            //Destroy(gameObject);
        }
    }
    
    IEnumerator DoSignRotation()
    {
        while (true)
        {
            LeanTween.rotateY(viewObjects[rand], 180f, rotateSpeed);
            yield return new WaitForSeconds(rotateSpeed);
            LeanTween.rotateY(viewObjects[rand], 360f, rotateSpeed);
            yield return new WaitForSeconds(rotateSpeed);
        }
    }

    IEnumerator DoDeath()
    {
        yield return new WaitForSeconds(timeToDie);
        UpdateManager.instance.RemoveObject(this);
        gameObject.SetActive(false);
        //Destroy(gameObject);
    }
    
}
