using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundPlayer : GenericObject
{
    public void PlaySound(int soundID)
    {
        SoundManager.instance.PlaySoundByID(soundID);
    }
}
