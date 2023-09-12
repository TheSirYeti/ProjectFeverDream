using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ResetTrigger : GenericObject
{
    private bool triggered = false;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player" && !triggered)
        {
            triggered = true;
            EventManager.Trigger("OnResetTriggerLevel");
            GameManager.Instance.ReloadScene();
        }

        if (other.gameObject.tag == "Robot")
        {
            gameObject.SetActive(false);
        }
        
    }
}
