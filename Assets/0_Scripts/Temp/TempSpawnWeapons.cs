using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TempSpawnWeapons : GenericObject
{
    public GameObject baguette, toaster;
    public override void OnUpdate()
    {
        if (Input.GetKeyDown(KeyCode.P))
        {
            GameObject newBaguette = Instantiate(baguette);
            newBaguette.transform.position = transform.position;
        }
        
        if (Input.GetKeyDown(KeyCode.O))
        {
            GameObject newToaster = Instantiate(toaster);
            newToaster.transform.position = transform.position;
        }
    }
}
