using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemySpawnTrigger : GenericObject
{
    private bool hasTriggered = false;
    [SerializeField] private List<EnemySpawner> enemySpawners;
    [SerializeField] private bool needsReposition;
    
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }
    
    private void OnTriggerEnter(Collider other)
    {
        if (hasTriggered || !other.gameObject.tag.Equals("Player")) return;

        foreach (var spawner in enemySpawners)
        {
            spawner.EnableEnemies(needsReposition);
        }

        hasTriggered = true;
    }
}
