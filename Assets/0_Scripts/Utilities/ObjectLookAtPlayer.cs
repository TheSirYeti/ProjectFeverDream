using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectLookAtPlayer : GenericObject
{
    public Transform target;
    int damp = 5;
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnUpdate()
    {
        if (target)
        {
            var rotationAngle = Quaternion.LookRotation ( target.position - transform.position);
            rotationAngle.x = 0;
            rotationAngle.y = 0;
            transform.rotation = Quaternion.Slerp ( transform.rotation, rotationAngle, Time.deltaTime * damp);
        }
    }
}
