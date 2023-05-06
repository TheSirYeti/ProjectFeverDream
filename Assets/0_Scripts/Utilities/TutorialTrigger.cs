using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TutorialTrigger : MonoBehaviour
{
    private bool hasTriggered = false;
    [SerializeField] private int tutorialID;

    private void OnTriggerEnter(Collider other)
    {
        if (!hasTriggered && other.gameObject.tag == "Player")
        {
            hasTriggered = true;
            EventManager.Trigger("OnTutorialTriggered", tutorialID);
        }
    }
}
