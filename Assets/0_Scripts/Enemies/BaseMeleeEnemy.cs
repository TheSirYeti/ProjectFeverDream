using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.ProBuilder.MeshOperations;
using Random = UnityEngine.Random;

public class BaseMeleeEnemy : Enemy
{
    [Space(50)] [Header("-== EXTRA MELEE ENEMY PROPERTIES ==-")] 
    [SerializeField] private string animationPrefix;
    [Space(20)]
    [Header("-== DETECT PROPERTIES ==-")]
    [SerializeField] private GameObject exclamationSign;
    [SerializeField] private float exclamationSignTimer;
    
    public enum MeleeEnemyStates
    {
        IDLE,
        DETECT,
        CHASING,
        PATHFIND,
        ATTACK,
        DIE
    }

    private EventFSM<MeleeEnemyStates> fsm;

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
        
        DoFsmSetup();
    }

    #region FSM SETUP

    void DoFsmSetup()
    {
        #region SETUP

        var idle = new State<MeleeEnemyStates>("IDLE");
        var detect = new State<MeleeEnemyStates>("DETECT");
        var chasing = new State<MeleeEnemyStates>("CHASING");
        var pathfind = new State<MeleeEnemyStates>("PATHFIND");
        var attack = new State<MeleeEnemyStates>("ATTACK");
        var die = new State<MeleeEnemyStates>("DIE");

        StateConfigurer.Create(idle)
            .SetTransition(MeleeEnemyStates.DETECT, detect)
            .SetTransition(MeleeEnemyStates.CHASING, chasing)
            .SetTransition(MeleeEnemyStates.PATHFIND, pathfind)
            .SetTransition(MeleeEnemyStates.ATTACK, attack)
            .SetTransition(MeleeEnemyStates.DIE, die)
            .Done();

        StateConfigurer.Create(detect)
            .SetTransition(MeleeEnemyStates.ATTACK, attack)
            .SetTransition(MeleeEnemyStates.CHASING, chasing)
            .SetTransition(MeleeEnemyStates.PATHFIND, pathfind)
            .SetTransition(MeleeEnemyStates.DIE, die)
            .Done();

        StateConfigurer.Create(chasing)
            .SetTransition(MeleeEnemyStates.IDLE, idle)
            .SetTransition(MeleeEnemyStates.PATHFIND, pathfind)
            .SetTransition(MeleeEnemyStates.ATTACK, attack)
            .SetTransition(MeleeEnemyStates.DIE, die)
            .Done();

        StateConfigurer.Create(pathfind)
            .SetTransition(MeleeEnemyStates.IDLE, idle)
            .SetTransition(MeleeEnemyStates.CHASING, chasing)
            .SetTransition(MeleeEnemyStates.ATTACK, attack)
            .SetTransition(MeleeEnemyStates.DIE, die)
            .Done();

        StateConfigurer.Create(attack)
            .SetTransition(MeleeEnemyStates.IDLE, idle)
            .SetTransition(MeleeEnemyStates.CHASING, chasing)
            .SetTransition(MeleeEnemyStates.PATHFIND, pathfind)
            .SetTransition(MeleeEnemyStates.DIE, die)
            .Done();

        StateConfigurer.Create(die).Done();

        #endregion

        #region IDLE

        idle.OnUpdate += () =>
        {
            if (isDead)
            {
                SendInputToFSM(MeleeEnemyStates.DIE);
                return;
            }

            if (!IsInFieldOfView()) return;

            if (!wasDetected)
            {
                SendInputToFSM(MeleeEnemyStates.DETECT);
                wasDetected = true;
                return;
            }

            if (IsInDistance())
            {
                isAttacking = true;
                SendInputToFSM(MeleeEnemyStates.ATTACK);
                return;
            }

            SendInputToFSM(MeleeEnemyStates.CHASING);
        };

        #endregion

        #region DETECT

        detect.OnEnter += x =>
        {
            animator.Play(animationPrefix + "_Detect");
            StopCoroutine(DoDetectSign());
            StartCoroutine(DoDetectSign());
        };
        
        detect.OnUpdate += () =>
        {
            transform.LookAt(
                new Vector3(target.transform.position.x, transform.position.y, target.transform.position.z));
        };

        #endregion

        #region CHASING

        chasing.OnUpdate += () =>
        {
            if (isDead)
            {
                SendInputToFSM(MeleeEnemyStates.DIE);
                return;
            }

            if (IsInDistance())
            {
                SendInputToFSM(MeleeEnemyStates.ATTACK);
                return;
            }

            if (!InSight(transform.position, target.transform.position))
            {
                SendInputToFSM(MeleeEnemyStates.PATHFIND);
                return;
            }

            SetSpeedValue(Time.deltaTime);
            DoGenericChase();
        };

        #endregion

        #region PATHFIND

        pathfind.OnEnter += x =>
        {
            CalculatePathPreview();
        };

        pathfind.OnUpdate += () =>
        {
            if (isDead)
            {
                Debug.Log("Case 1");
                SendInputToFSM(MeleeEnemyStates.DIE);
                return;
            }

            if (IsInDistance())
            {
                SendInputToFSM(MeleeEnemyStates.ATTACK);
                return;
            }

            if (InSight(transform.position, target.transform.position))
            {
                SendInputToFSM(MeleeEnemyStates.CHASING);
                return;
            }
            
            SetSpeedValue(Time.deltaTime);
            DoPathfinding();
        };

        #endregion

        #region ATTACK

        attack.OnUpdate += () =>
        {
            if (isDead)
            {
                SendInputToFSM(MeleeEnemyStates.DIE);
                return;
            }

            if (!IsInDistance() && !isAttacking)
            {
                SendInputToFSM(MeleeEnemyStates.CHASING);
                return;
            }
            
            Attack();
        };

        #endregion

        fsm = new EventFSM<MeleeEnemyStates>(idle);
    }

    private void SendInputToFSM(MeleeEnemyStates state)
    {
        fsm.SendInput(state);
    }

    IEnumerator DoDetectSign()
    {
        exclamationSign.SetActive(true);
        yield return new WaitForSeconds(exclamationSignTimer);
        exclamationSign.SetActive(false);
        
        SendInputToFSM(MeleeEnemyStates.CHASING);
        yield return null;
    }
    
    #endregion
    

    public override void Attack()
    {
        transform.LookAt(new Vector3(target.transform.position.x, transform.position.y, target.transform.position.z));

        if (currentAttackCooldown > 0) return;
        
        currentAttackCooldown = attackCooldown;
        animator.SetTrigger("punch");
        StopSpeed();
    }

    public override void Death()
    {
        if (isDead) return;
        
        DoWarningFadeOut();
        
        EventManager.Trigger("OnDamageableHit", 3);

        DoRagdoll();
        isDead = true;
    }

    public override void Move()
    {
        SetSpeedValue(Time.deltaTime);

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
        currentAttackCooldown -= Time.deltaTime;
        pathfindingCooldown -= Time.deltaTime;
        
        fsm.Update();
        
        /*if (isDead) return;
        
        if (IsInDistance())
        {
            Attack();
            return;
        }
        
        if(!isAttacking)
            Move();*/
    }

    #region EXTRA VIEW METHODS

    public void DoWarningFadeIn()
    {
        isAttacking = true;
        foreach (var renderer in renderers)
        {
            LeanTween.value(0, 1, 0.3f).setOnUpdate((float value) =>
            {
                renderer.material.SetFloat("_ValueWarning", value);
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
                renderer.material.SetFloat("_ValueWarning", value);
            });
        }
    }

    public override void DoKnockback()
    {
        animator.Play(animationPrefix + "_Knockback");
    }

    #endregion
}
