using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TutorialTrigger : GenericObject
{
    private bool hasTriggered = false;
    [SerializeField] private int tutorialID;

    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }
    
    private void OnTriggerEnter(Collider other)
    {
        if (!hasTriggered && other.gameObject.CompareTag("Player"))
        {
            hasTriggered = true;
            EventManager.Trigger("OnTutorialTriggered", tutorialID);
        }
    }
}
