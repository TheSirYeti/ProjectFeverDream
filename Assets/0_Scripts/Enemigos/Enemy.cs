using System.Collections;
using System.Collections.Generic;
using System.Security;
using UnityEngine;

public abstract class Enemy : MonoBehaviour
{
    [Header("Base Properties")]
    [SerializeField] protected float hp;
    [Space(10)]

    [Header("Target Properties")]
    [SerializeField] protected GameObject target;
    [SerializeField] private float minChaseDistance;

    [Header("Attack Properties")] 
    [SerializeField] protected float attackCooldown;
    [SerializeField] protected float currentAttackCooldown;
    [SerializeField] protected bool isAttacking;
    
    [Header("Movement Properties")] 
    [SerializeField] protected float speed;
    protected float maxSpeed;
    [SerializeField] private float accelerationValue;

    [Header("Ragdoll Properties")] 
    [SerializeField] private Rigidbody rb;
    [SerializeField] private bool hasRagdoll;
    private bool isInRagdollMode = false;
    Rigidbody[] ragdollRigidbodies;

    [Header("View Properties")]
    [SerializeField] protected Animator animator;
    [Space(10)] 
    [SerializeField] protected List<Renderer> renderers;

    #region RAGDOLLS

    public void DoRagdoll()
    {
        if (!hasRagdoll)
            return;
        
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
        if (!hasRagdoll)
            return;
        
        isInRagdollMode = false;

        foreach (var rigidbody in ragdollRigidbodies)
        {
            rigidbody.isKinematic = true;
        }
        
        //collider.enabled = true;
        rb.isKinematic = false;
        animator.enabled = true;
    }

    #endregion
    
    public abstract void TakeDamage();
    public abstract void Attack();
    public abstract void Move();

    #region MOVEMENT

    public void SetSpeedValue(float value)
    {
        if (speed >= maxSpeed)
        {
            speed = maxSpeed;
            return;
        }

        speed += value * accelerationValue;
    }

    protected void StopSpeed()
    {
        speed = 0;
    }
    
    protected void DoGenericChase()
    {
        transform.forward = target.transform.position - transform.position;
        
        transform.LookAt(new Vector3(target.transform.position.x, transform.position.y, target.transform.position.z));
        transform.position += transform.forward * speed * Time.deltaTime;
    }

    protected bool IsInDistance()
    {
        return Vector3.Distance(target.transform.position, transform.position) <= minChaseDistance;
    }

    #endregion
}
