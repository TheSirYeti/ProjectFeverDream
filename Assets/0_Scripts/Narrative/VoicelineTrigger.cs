using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VoicelineTrigger : GenericObject
{
    public SubtitleSet mySet;
    private bool hasBeenTriggered = false;
    private void OnTriggerEnter(Collider other)
    {
        if (!hasBeenTriggered && other.gameObject.tag == "Player")
        {
            EventManager.Trigger("OnVoicelineSetTriggered", mySet);
            hasBeenTriggered = true;
        }
    }
}
