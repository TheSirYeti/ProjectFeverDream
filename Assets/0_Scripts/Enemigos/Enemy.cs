using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class Enemy : MonoBehaviour
{
    [Header("Base Properties")]
    [SerializeField] private float hp;

    [Header("Movement Properties")]
    [SerializeField] private float speed;

    [Header("Ragdoll Properties")] 
    [SerializeField] private Rigidbody rb;
    private bool isInRagdollMode = false;
    Rigidbody[] ragdollRigidbodies;

    [Header("Animator Properties")]
    [SerializeField] private Animator animator;
    
    
    public void DoRagdoll() 
    {
        isInRagdollMode = true;

        foreach (var rigidbody in ragdollRigidbodies)
        {
            rigidbody.isKinematic = false;
        }
        
        //collider.enabled = false;
        rb.isKinematic = true;
        animator.enabled = false;
    }

    public void StopRagdoll()
    {
        isInRagdollMode = false;

        foreach (var rigidbody in ragdollRigidbodies)
        {
            rigidbody.isKinematic = true;
        }
        
        //collider.enabled = true;
        rb.isKinematic = false;
        animator.enabled = true;
    }
}
