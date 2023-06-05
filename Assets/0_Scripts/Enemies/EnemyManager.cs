using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class EnemyManager : GenericObject
{
    public Dictionary<int, List<Enemy>> enemySets = new Dictionary<int, List<Enemy>>();
    public List<GameObject> sets;

    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    public override void OnStart()
    {
        EventManager.Subscribe("OnEnemyDetection", EnableEnemies);
        
        int counter = 0;
        foreach (var set in sets)
        {
            var enemyList = set.GetComponentsInChildren<Enemy>().ToList();

            foreach (var enemy in enemyList)
            {
                enemy.SetEnemySetID(counter);
            }

            enemySets.Add(counter, enemyList);
            counter++;
        }
    }

    public void EnableEnemies(object[] parameters)
    {
        int id = (int)parameters[0];
        
        if (enemySets.ContainsKey(id))
        {
            var enemies = enemySets[id];

            foreach (var enemy in enemies)
            {
                enemy.SetDetection();
            }
        }
    }
}
