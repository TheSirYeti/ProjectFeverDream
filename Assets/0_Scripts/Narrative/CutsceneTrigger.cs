using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CutsceneTrigger : GenericObject
{
    private bool hasTriggered = false;
    public int timelineID;
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    public override void OnStart()
    {

    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player" && !hasTriggered)
        {
            hasTriggered = true;
            SoundManager.instance.StopAllSounds();
            SoundManager.instance.StopAllMusic();
            SoundManager.instance.StopAllVoiceLines();
            CutsceneManager.instance.PlayTimeline(timelineID);
        }
    }
}
