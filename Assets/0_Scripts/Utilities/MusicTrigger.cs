using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MusicTrigger : GenericObject
{
    private bool hasBeenTriggered = false;
    [SerializeField] private MusicID musicID;
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player" && !hasBeenTriggered)
        {
            hasBeenTriggered = true;
            SoundManager.instance.PlayMusic(musicID);
        }
        
    }
}
