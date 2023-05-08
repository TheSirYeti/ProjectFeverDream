using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TempSpawnWeapons : MonoBehaviour
{
    public GameObject baguette, toaster;
    private void Update()
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
