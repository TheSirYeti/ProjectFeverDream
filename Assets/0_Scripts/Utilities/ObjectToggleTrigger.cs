using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectToggleTrigger : GenericObject
{
    public GameObject obj;
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            obj.SetActive(true);
        }
    }
}
