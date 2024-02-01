using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SpatialSound : GenericObject
{
    [Header("SFX's")]
    [SerializeField] AudioSource audioSource;
    private int audioID;

    [Space(10)] 
    [Header("Properties")] 
    [SerializeField] private bool playOnStart;
    [SerializeField] private bool playOnEnable;
    [SerializeField] private bool loop;
    
 
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnStart()
    {
        audioID = SoundManager.instance.AddSFXSource(audioSource);

        if(playOnStart)
            PlaySound();
    }

    public void PlaySound()
    {
        SoundManager.instance.PlaySoundByInt(audioID, loop);
    }

    private void OnEnable()
    {
        if(playOnEnable)
            PlaySound();
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.cyan;
        Gizmos.DrawWireSphere(transform.position, 1f);
    }
}
