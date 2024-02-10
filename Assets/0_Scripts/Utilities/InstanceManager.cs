using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InstanceManager : GenericObject
{
    public static InstanceManager instance;
    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
            UpdateManager.instance.AddObject(this);
        }
        else Destroy(gameObject);
    }
}
