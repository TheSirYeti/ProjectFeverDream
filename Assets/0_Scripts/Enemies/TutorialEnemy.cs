using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TutorialEnemy : Enemy
{
    private void Start()
    {
        if (!_damageRecive.ContainsKey("WeakPart"))
            _damageRecive.Add("WeakPart", weakDmg);

        if (!_damageRecive.ContainsKey("Head"))
            _damageRecive.Add("Head", headDmg);

        if (!_damageRecive.ContainsKey("Body"))
            _damageRecive.Add("Body", bodyDmg);

        if (!_damageRecive.ContainsKey("Generic"))
            _damageRecive.Add("Generic", generalDmg);
        
        if (target == null)
        {
            target = GameObject.FindWithTag("Player");
        }

        ragdollRigidbodies = GetComponentsInChildren<Rigidbody>();
        
        maxHP = hp;
        maxSpeed = speed;
        speed = 0;
    }

    public override void Attack()
    {
        
    }

    public override void Move()
    {
        
    }

    public override void Death()
    {
        EventManager.Trigger("OnDamageableHit", 3);

        DoRagdoll();
        isDead = true;
    }

    public override void DoKnockback()
    {
        
    }
}
