using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ParticlePlayer : GenericObject
{
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public ParticleSystem particleSystem;

    private void OnEnable()
    {
        particleSystem.Play();
    }
}
