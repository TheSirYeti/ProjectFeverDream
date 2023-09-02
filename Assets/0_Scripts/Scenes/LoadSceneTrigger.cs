using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LoadSceneTrigger : GenericObject
{
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }
    
    public override void OnStart()
    {
        SceneLoader.instance.StartNewSceneLoad();
    }
}
