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
    
    public void OnLevelOver()
    {
        EventManager.Trigger("OnCutsceneEvent", true);
        EventManager.Trigger("OnPPCalled", PPNames.BORDERCINEMATIC, false);
        GameManager.Instance.NextScene();
    }
}
