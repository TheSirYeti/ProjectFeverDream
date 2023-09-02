using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InteractAutoAimSystem : GenericObject
{
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }
}
