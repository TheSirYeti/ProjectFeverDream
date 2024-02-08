using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CrowdCheering : GenericObject
{
    [SerializeField] private AudioSource _normalCrowdSFX, _laughCrowdSFX, _clapCrowdSFX;
    private int _normalCrowdID, _laughCrowdID, _clapCrowdID;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnStart()
    {
        _normalCrowdID = SoundManager.instance.AddSFXSource(_normalCrowdSFX);
        _laughCrowdID = SoundManager.instance.AddSFXSource(_laughCrowdSFX);
        _clapCrowdID = SoundManager.instance.AddSFXSource(_clapCrowdSFX);
        
        EventManager.Subscribe("OnPlateFinished", DoClapping);
        EventManager.Subscribe("ChangeHealthUI", DoLaughter);
    }

    private void OnEnable()
    {
        SoundManager.instance.PlaySoundByInt(_normalCrowdID, true);
    }

    void DoLaughter(object[] parameters)
    {
        SoundManager.instance.PlaySoundByInt(_laughCrowdID);
    }
    
    void DoClapping(object[] parameters)
    {
        SoundManager.instance.PlaySoundByInt(_clapCrowdID);
    }
}
