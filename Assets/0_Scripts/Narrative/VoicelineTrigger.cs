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

    public ObjectiveData objData;
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
            
            if(objData != null)
                objData.ChangeObjective(null);
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
            return;
        }
        EventManager.Trigger("OnVoicelineStopTriggered");
    }
}
