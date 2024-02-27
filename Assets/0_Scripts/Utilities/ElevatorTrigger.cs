using System;
using System.Collections;
using System.Collections.Generic;
using System.Transactions;
using UnityEngine;

public class ElevatorTrigger : GenericObject
{
    private Animator animator;
    private bool wasTriggered;
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
        animator = GetComponent<Animator>();
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player" && !wasTriggered)
        {
            wasTriggered = true;
            animator.Play("CloseDoor 2");
        }
    }
}
