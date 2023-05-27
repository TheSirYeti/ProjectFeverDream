using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LoadSceneTrigger : GenericObject
{
    public override void OnStart()
    {
        SceneLoader.instance.StartNewSceneLoad();
    }
}
