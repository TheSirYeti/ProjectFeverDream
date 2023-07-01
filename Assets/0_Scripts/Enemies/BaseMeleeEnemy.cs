using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Runtime.CompilerServices;
using UnityEngine;
using UnityEngine.Networking.Types;
using UnityEngine.ProBuilder.MeshOperations;
using Random = UnityEngine.Random;

public class BaseMeleeEnemy : Enemy
{
    [Space(50)] [Header("-== EXTRA MELEE ENEMY PROPERTIES ==-")] 
    [SerializeField] private string animationPrefix;
    [SerializeField] private int attackAnimationCount = 4;
    [Space(15)] 
    [SerializeField] private List<GameObject> myWeapons;
    private bool hasAttacked = false;
    private TrailRenderer trailRenderer;
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

    public override void OnStart()
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
        StopRagdoll();

        if (myWeapons.Count > 0)
        {
            int rand = Random.Range(0, myWeapons.Count);
            myWeapons[rand].SetActive(true);

            trailRenderer = myWeapons[rand].GetComponentInChildren<TrailRenderer>();
            trailRenderer.enabled = false;
        }

        maxHP = hp;
        maxSpeed = speed;
        speed = 0;

        foreach (var sfx in audioSources)
        {
            audioIDs.Add(SoundManager.instance.AddSFXSource(sfx));
        }
        
        foreach (var sfx in detectSFX)
        {
            audioDetectIDs.Add(SoundManager.instance.AddSFXSource(sfx));
        }
        
        EventManager.Subscribe("OnResetTriggerLevel", OnResetScene);
        
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
            DoFaceTransition(FaceID.DETECT);
            animator.Play(animationPrefix + "_Detect");
            StopCoroutine(DoDetectSign());
            StartCoroutine(DoDetectSign());
            EventManager.Trigger("OnFirstDetection");
            //PlayRandomDetectGreet();
        };
        
        detect.OnUpdate += () =>
        {
            transform.LookAt(
                new Vector3(target.transform.position.x, transform.position.y, target.transform.position.z));
        };

        detect.OnExit += x =>
        {
            EventManager.Trigger("OnEnemyDetection", enemySet);
            DoFaceTransition(FaceID.COMBAT);
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
            CalculatePathPreview(false);
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

            if (!IsInDistance() && hasAttacked)
            {
                SendInputToFSM(MeleeEnemyStates.CHASING);
                return;
            }
            
            Attack();
        };

        attack.OnExit += x =>
        {
            hasAttacked = false;
        };

        #endregion

        #region DEAD

        die.OnEnter += x =>
        {
            DisableAttackRegion();
            SoundManager.instance.PlaySound(SoundID.ENEMY_GENERIC_DEATH);
            DoFaceTransition(FaceID.DEAD);
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
        if(exclamationSign != null)
            exclamationSign.SetActive(true);
        
        yield return new WaitForSeconds(exclamationSignTimer);
        
        if(exclamationSign != null)
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

        int rand = Random.Range(1, attackAnimationCount + 1);
        animator.Play("Enemy_Melee_Attack" + rand);
        StopSpeed();
    }

    public override void SetDetection()
    {
        if (wasDetected) return;
        
        DoFaceTransition(FaceID.COMBAT);
        wasDetected = true;
        SendInputToFSM(MeleeEnemyStates.CHASING);
    }

    public override void Death()
    {
        if (isDead) return;
        
        DoWarningFadeOut();

        foreach (var particle in deathShockParticles)
        {
            particle.Play();
        }
        
        EventManager.Trigger("OnDamageableHit", 3);

        DoRagdoll();
        StartCoroutine(FreezeAllRigidbodies());
        
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
            if (isPathfinding)
            {
                DoPathfinding();
            }
            else
            {
                CalculatePathPreview(false);
            }
            return;
        }
        
        isPathfinding = false;
        //nodePath.Clear();
        
        DoGenericChase();
    }

    public override void OnUpdate()
    {
        if (!_canMove) return;
        
        fsm.Update();
        
        if (isDead) return;
        
        animator.SetFloat("movementSpeed", speed);
        currentAttackCooldown -= Time.deltaTime;
        pathfindingCooldown -= Time.deltaTime;
    }

    public void PlayRandomSlash()
    {
        int rand = Random.Range(0, audioIDs.Count);
        PlayAudioSource(audioIDs[rand]);
    }

    public void PlayRandomDetectGreet()
    {
        int rand = Random.Range(0, audioDetectIDs.Count);
        PlayAudioSource(audioDetectIDs[rand]);
    }

    public void PlayAudioSource(int sourceID)
    {
        SoundManager.instance.PlaySoundByInt(sourceID);
    }
    
    public void StopAudioSource(int sourceID)
    {
        SoundManager.instance.StopSoundByInt(sourceID);
    }

    #region EXTRA VIEW METHODS

    public void DoWarningFadeIn()
    {
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

    public void EnableAttackRegion()
    {
        attackCollider.enabled = true;
        trailRenderer.enabled = true;
        isAttacking = true;
    }

    public void DisableAttackRegion()
    {
        attackCollider.enabled = false;
        trailRenderer.enabled = false;
        isAttacking = false;
    }

    public void StopCurrentAttack()
    {
        hasAttacked = true;
    }

    #endregion
}
