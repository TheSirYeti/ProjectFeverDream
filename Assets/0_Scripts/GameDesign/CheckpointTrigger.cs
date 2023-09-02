using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CheckpointTrigger : GenericObject
{
    private bool isTriggered = false;
    private int checkpointID;
    [SerializeField] private Transform spawnpoint;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }
    
    private void OnTriggerEnter(Collider other)
    {
        if (isTriggered || !other.gameObject.tag.Equals("Player")) return;

        isTriggered = true;
        EventManager.Trigger("OnCheckpointTriggered", checkpointID);
    }

    public void SetID(int id)
    {
        checkpointID = id;
    }

    public Transform GetSpawnpoint()
    {
        return spawnpoint;
    }
}
