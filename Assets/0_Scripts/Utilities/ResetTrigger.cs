using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ResetTrigger : GenericObject
{
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            EventManager.Trigger("OnResetTriggerLevel");
            GameManager.Instance.ReloadScene();
        }
        
    }
}
