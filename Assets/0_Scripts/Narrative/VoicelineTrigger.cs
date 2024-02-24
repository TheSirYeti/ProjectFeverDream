using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VoicelineTrigger : GenericObject
{
    public SubtitleSet mySet;
    private bool hasBeenTriggered = false;

    public bool doOnEnable = false;
    public bool isForStopping = false;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }
    
    private void OnTriggerEnter(Collider other)
    {
        if (!hasBeenTriggered && other.gameObject.tag == "Player")
        {
            hasBeenTriggered = true;
            DoVoicelineFunc();
        }
    }

    public void OnEnable()
    {
        if(doOnEnable)
            DoVoicelineFunc();
    }

    void DoVoicelineFunc()
    {
        if (!isForStopping)
        {
            EventManager.Trigger("OnVoicelineSetTriggered", mySet);
            hasBeenTriggered = true;
            Debug.Log("FUNCO2");
            return;
        }
        Debug.Log("NO FUNCO");
        EventManager.Trigger("OnVoicelineStopTriggered");
    }
}
