using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaseMeleeEnemy : Enemy
{
    private void Start()
    {
        maxSpeed = speed;
        speed = 0;
    }

    public override void TakeDamage()
    {
        throw new System.NotImplementedException();
    }

    public override void Attack()
    {
        if (currentAttackCooldown <= 0)
        {
            currentAttackCooldown = attackCooldown;
            animator.SetTrigger("punch");
        }
        
        StopSpeed();
    }

    public override void Move()
    {
        SetSpeedValue(Time.deltaTime);
        currentAttackCooldown--;

        if (!IsInDistance())
        {
            DoGenericChase();
        }
        else StopSpeed();
    }

    private void Update()
    {
        animator.SetFloat("movementSpeed", speed);
        Debug.Log(speed);
        
        if (IsInDistance())
        {
            Attack();
            return;
        }
        
        if(!isAttacking)
            Move();
    }

    #region EXTRA VIEW METHODS

    public void DoWarningFadeIn()
    {
        isAttacking = true;
        foreach (var renderer in renderers)
        {
            LeanTween.value(0, 1, 0.3f).setOnUpdate((float value) =>
            {
                renderer.material.SetFloat("_WarningValue", value);
            });
        }
    }
    
    public void DoWarningFadeOut()
    {
        isAttacking = false;
        foreach (var renderer in renderers)
        {
            LeanTween.value(1, 0, 0.3f).setOnUpdate((float value) =>
            {
                renderer.material.SetFloat("_WarningValue", value);
            });
        }
    }

    #endregion
}
