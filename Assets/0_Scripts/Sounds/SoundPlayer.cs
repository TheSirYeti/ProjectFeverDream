using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundPlayer : GenericObject
{
    public string soundID, musicID;
    public bool playSoundOnStart, playMusicOnStart;
    public bool playSoundOnEnable, playMusicOnEnable;
    
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnStart()
    {
        if(playMusicOnStart)
            PlayMusic(musicID);

        if (playSoundOnStart)
            PlaySound(soundID);
    }

    public void PlaySound(string soundID)
    {
        SoundManager.instance.PlaySoundByID(soundID);
    }
    
    public void PlayMusic(string musicID)
    {
        SoundManager.instance.PlayMusicByID(musicID);
    }

    private void OnEnable()
    {
        if(playMusicOnEnable)
            PlayMusic(musicID);

        if (playSoundOnEnable)
            PlaySound(soundID);
    }
}
