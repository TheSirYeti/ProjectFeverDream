using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SoundProfileTrigger : GenericObject
{
    [SerializeField] private int soundID;
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }
    
    private void OnTriggerEnter(Collider other)
    {
        IPlayerLife playerLife = other.GetComponentInParent<IPlayerLife>();

        if (playerLife != null)
        {
            EventManager.Trigger("OnRoomEnter", soundID);
        }
    }
}
