using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using Random = UnityEngine.Random;

public class EnemyManager : GenericObject
{ 
    Dictionary<int, List<Enemy>> enemySets = new Dictionary<int, List<Enemy>>();
    [SerializeField] private List<GameObject> sets;

    [SerializeField] private int detectGreetsCount = 7;
    [SerializeField] private float detectDialogueCooldown = 5f;
    [SerializeField] private float currentDetectDialogueCooldown = 0;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnStart()
    {
        EventManager.Subscribe("OnEnemyDetection", EnableEnemies);
        EventManager.Subscribe("OnLevelFinished", DisableAllEnemies);
        EventManager.Subscribe("OnFirstDetection", DoEnemyDetectDialogue);
        
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

    public override void OnUpdate()
    {
        currentDetectDialogueCooldown -= Time.deltaTime;
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

    public void DisableAllEnemies(object[] parameters)
    {
        foreach (var enemies in sets)
        {
            enemies.SetActive(false);
        }
    }

    void DoEnemyDetectDialogue(object[] parameters)
    {
        if (currentDetectDialogueCooldown <= 0)
        {
            currentDetectDialogueCooldown = detectDialogueCooldown;
            SoundManager.instance.PlaySoundByID("ENEMY_DETECT_" + Random.Range(1, detectGreetsCount + 1));
        }
    }
}
