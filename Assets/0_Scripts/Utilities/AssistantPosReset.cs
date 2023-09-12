using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AssistantPosReset : GenericObject
{
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            GameManager.Instance.Assistant.ResetGeorge();
        }
    }
}
