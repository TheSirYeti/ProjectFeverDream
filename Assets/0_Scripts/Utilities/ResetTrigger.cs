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
            if (other.gameObject.GetComponent<Enemy>().myWall != null) 
                other.gameObject.GetComponent<Enemy>().myWall.AddDeathToll();
            
            gameObject.SetActive(false);
            
        }
        
    }
}
