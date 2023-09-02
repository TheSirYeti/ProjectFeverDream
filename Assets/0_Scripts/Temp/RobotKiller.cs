using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RobotKiller : GenericObject
{
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Robot")
        {
            other.gameObject.SetActive(false);
        }
    }
}
