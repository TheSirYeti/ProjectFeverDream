using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MPathfinding : GenericObject
{
    public static MPathfinding _instance;

    private void Awake()
    {
        //TODO: Add subscribe to updatemanager
        _instance = this;
    }

    
}
