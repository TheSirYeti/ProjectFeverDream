using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ToastBullet : GenericBullet
{
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }
    
    public override void OnUpdate()
    {
        Movement();
    }
}
