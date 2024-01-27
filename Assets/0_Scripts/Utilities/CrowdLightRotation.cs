using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = System.Random;

public class CrowdLightRotation : GenericObject
{
    private Vector3 _randomRotations;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnUpdate()
    {
        float randX = UnityEngine.Random.Range(0.5f, 1.5f);
        float randY = UnityEngine.Random.Range(0.1f, 1f);
        float randZ = UnityEngine.Random.Range(0.5f, 1.5f);

        _randomRotations = new Vector3(randX, randY, randZ);
        
        transform.Rotate(_randomRotations);
    }
}
