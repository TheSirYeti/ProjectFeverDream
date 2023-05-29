using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundPlayer : GenericObject
{
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }
    
    public void PlaySound(string soundID)
    {
        SoundManager.instance.PlaySoundByID(soundID);
    }
}
