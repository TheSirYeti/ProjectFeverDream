using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.ProBuilder.MeshOperations;

public class BaseMeleeEnemy : Enemy
{
    private void Start()
    {
        maxSpeed = speed;
        speed = 0;
    }

    public override void TakeDamage()
    {
        //throw new System.NotImplementedException();
    }

    public override void Attack()
    {
        transform.LookAt(new Vector3(target.transform.position.x, transform.position.y, target.transform.position.z));

        if (currentAttackCooldown <= 0)
        {
            currentAttackCooldown = attackCooldown;
            Debug.Log("HIT!");
            animator.SetTrigger("punch");
        }
        
        StopSpeed();
    }

    public override void Move()
    {
        SetSpeedValue(Time.deltaTime);
        currentAttackCooldown -= Time.deltaTime;
        pathfindingCooldown -= Time.deltaTime;

        if (IsInDistance())
        {
            StopSpeed();
            return;
        }
        
        if (!InSight(transform.position, target.transform.position))
        {
            if (isPathfinding && nodePath.Any())
            {
                DoPathfinding();
            }
            else
            {
                CalculatePathPreview();
            }
            return;
        }
        
        isPathfinding = false;
        nodePath.Clear();
        
        DoGenericChase();
    }

    private void Update()
    {
        animator.SetFloat("movementSpeed", speed);

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
