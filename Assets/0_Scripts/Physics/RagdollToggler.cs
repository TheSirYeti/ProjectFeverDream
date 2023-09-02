using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RagdollToggler : GenericObject
{
    private Rigidbody rb;
    private Animator animator;
    public List<Rigidbody> ragdollRigidbodies;
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnStart()
    {
        animator = GetComponent<Animator>();
        //rb = GetComponent<Rigidbody>();
        StopRagdoll();
    }
    
    public void DoRagdoll()
    {
        foreach (var rigidbody in ragdollRigidbodies)
        {
            if(rigidbody != rb)
                rigidbody.isKinematic = false;
        }
        
        //rb.isKinematic = true;
        animator.enabled = false;
    }

    public void StopRagdoll()
    {
        foreach (var rigidbody in ragdollRigidbodies)
        {
            if(rigidbody != rb)
                rigidbody.isKinematic = true;
        }
        
        //rb.isKinematic = false;
        animator.enabled = true;
    }
}
