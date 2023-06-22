using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VoicelineTrigger : GenericObject
{
    public SubtitleSet mySet;
    private bool hasBeenTriggered = false;

    public bool doOnEnable = false;
    
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }
    
    private void OnTriggerEnter(Collider other)
    {
        if (!hasBeenTriggered && other.gameObject.tag == "Player")
        {
            EventManager.Trigger("OnVoicelineSetTriggered", mySet);
            hasBeenTriggered = true;
        }
    }

    public void OnEnable()
    {
        if (doOnEnable)
        {
            EventManager.Trigger("OnVoicelineSetTriggered", mySet);
            hasBeenTriggered = true;
        }
    }
}
