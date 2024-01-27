using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BossCutsceneSignals : GenericObject
{
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }
    
    
}
