using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CutsceneToggler : GenericObject
{
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    private void OnEnable()
    {
        EventManager.Trigger("ChangeMovementState", false);
    }
    
    private void OnDisable()
    {
        EventManager.Trigger("ChangeMovementState", true);
    }
}
