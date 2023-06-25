using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EndLevelTrigger : GenericObject
{
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    public override void OnStart()
    {

    }
}
