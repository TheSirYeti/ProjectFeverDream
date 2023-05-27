using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemySpawner : GenericObject
{
    [SerializeField] private List<GameObject> enemiesToEnable;
    [SerializeField] private Transform spawnpoint;
    [Space(20)] [SerializeField] private float gizmoViewRadius;
    [SerializeField] private Color gizmoColor;

    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }
    
    public override void OnStart()
    {
        foreach (var enemy in enemiesToEnable)
        {
            enemy.SetActive(false);
        }
    }

    public void EnableEnemies(bool needsReposition = false)
    {
        foreach (var enemy in enemiesToEnable)
        {
            enemy.SetActive(true);
            
            if (needsReposition)
            {
                enemy.transform.position = transform.position;
            }
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = gizmoColor;
        Gizmos.DrawSphere(transform.position, gizmoViewRadius);
    }
}
