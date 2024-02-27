using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CloseDoors : GenericObject
{
    public GameObject openDoors, closedDoors;
    private bool hasTriggered = false;
    public Animator animator;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
        
        EventManager.Subscribe("OnFirstWeapon", OpenDoors);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player" && !hasTriggered)
        {
            var assistant = GameManager.Instance.Assistant;
            assistant.ResetGeorge();
            assistant.transform.position = GameManager.Instance.Player.transform.position;
            
            animator.Play("RestaurantDoorsClose");
            hasTriggered = true;
        }
    }

    void OpenDoors(object[] parameters)
    {
        animator.Play("RestaurantDoorsOpen");
    }
}
