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
        if (other.gameObject.tag == "EP_Chef" || other.gameObject.tag == "EP_Waiter")
        {
            other.gameObject.SetActive(false);
        }
    }
}
