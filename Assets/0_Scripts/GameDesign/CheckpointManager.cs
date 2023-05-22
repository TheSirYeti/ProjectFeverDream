using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

public class CheckpointManager : MonoBehaviour
{
    private int currentCheckpoint;
    [SerializeField] private List<CheckpointTrigger> checkpoints;
    [SerializeField] private Transform playerPos;
    
    private void Start()
    {
        if (!PlayerPrefs.HasKey("CurrentCheckpoint"))
        {
            Debug.Log("Huh?");
            PlayerPrefs.SetInt("CurrentCheckpoint", 0);
        }

        for (int i = 0; i < checkpoints.Count; i++)
        {
            checkpoints[i].SetID(i);
        }
        
        EventManager.Subscribe("OnCheckpointTriggered", SetNewCheckpoint);
        EventManager.Subscribe("OnNewSceneLoaded", ResetCheckpoints);

        currentCheckpoint = PlayerPrefs.GetInt("CurrentCheckpoint");
        DoPlayerSpawn();
    }

    void SetNewCheckpoint(object[] parameters)
    {
        int newCheckpoint = (int)parameters[0];

        if (newCheckpoint < currentCheckpoint) return;
        
        currentCheckpoint = newCheckpoint;
        PlayerPrefs.SetInt("CurrentCheckpoint", currentCheckpoint);
    }

    void DoPlayerSpawn()
    {
        playerPos.position = checkpoints[currentCheckpoint].GetSpawnpoint().position;
    }

    void ResetCheckpoints(object[] parameters)
    {
        PlayerPrefs.SetInt("CurrentCheckpoint", 0);
    }

    private void OnApplicationQuit()
    {
        PlayerPrefs.SetInt("CurrentCheckpoint", 0);
    }
}
