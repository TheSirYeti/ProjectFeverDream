using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CloseDoors : GenericObject
{
    public GameObject openDoors, closedDoors;
    private bool hasTriggered = false;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player" && !hasTriggered)
        {
            var assistant = GameManager.Instance.Assistant;
            assistant.ResetGeorge();
            assistant.transform.position = GameManager.Instance.Player.transform.position;
            
            closedDoors.SetActive(true);
            openDoors.SetActive(false);
            hasTriggered = true;
        }
    }
}
