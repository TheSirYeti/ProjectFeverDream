using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraSetterInScene : GenericObject
{
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnAwake()
    {
        GameManager.Instance.SetCameraParent(transform);
    }
}
