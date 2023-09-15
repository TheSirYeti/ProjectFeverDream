using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.PlayerLoop;

public class EnemyWallChecker : GenericObject
{
    [SerializeField] private GameObject myWall;
    [SerializeField] private List<Enemy> wallEnemies;
    private int deathToll, currentDeathToll = 0;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnStart()
    {
        deathToll = wallEnemies.Count;

        foreach (var enemy in wallEnemies)
        {
            enemy.myWall = this;
        }
    }

    public void AddDeathToll()
    {
        currentDeathToll++;
        Debug.Log("CURRENT = " + currentDeathToll + ", DEATH TOLL = " + deathToll);
        
        if(currentDeathToll >= deathToll)
            myWall.SetActive(false);
    }
}
