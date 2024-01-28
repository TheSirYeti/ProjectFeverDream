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

    public void OnStopChef()
    {
        EventManager.Trigger("OnPlateFinished");
    }

    public void OnHitOver()
    {
        EventManager.Trigger("OnNextRecipe");
    }
}
