using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundToggler : GenericObject
{
    [SerializeField] private List<GameObject> _allSoundProfiles;
    private GameObject _currentSoundProfile, _lastSoundProfile;
    private int _currentID = -1;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnStart()
    {
        EventManager.Subscribe("OnRoomEnter", SetActiveSoundProfile);
    }

    private void SetActiveSoundProfile(object[] parameters)
    {
        int id = (int)parameters[0];

        if (_currentID == id) return;
        _currentID = id;
        
        foreach (var sfxProfile in _allSoundProfiles)
        {
            sfxProfile.SetActive(false);
        }
        
        if (_currentSoundProfile != null)
        {
            _lastSoundProfile = _currentSoundProfile;
            _lastSoundProfile.SetActive(true);
        }
        
        _currentSoundProfile = _allSoundProfiles[id];
        _currentSoundProfile.SetActive(true);
    }
}
