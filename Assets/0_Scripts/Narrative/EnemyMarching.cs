using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyMarching : GenericObject
{
    [SerializeField] private float timeToMarch;
    [SerializeField] private GameObject enemies;
    [SerializeField] private Transform startPosition, endPosition;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnStart()
    {
        StartCoroutine(DoMarch());
    }

    IEnumerator DoMarch()
    {
        while (true)
        {
            Vector3 startPos = new Vector3(startPosition.position.x, enemies.transform.position.y, enemies.transform.position.z);
            LeanTween.moveX(enemies, endPosition.position.x, timeToMarch);
            yield return new WaitForSeconds(timeToMarch);
            enemies.transform.position = startPos;
        }
    }
}
