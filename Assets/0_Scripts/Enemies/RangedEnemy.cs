using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class RangedEnemy : Enemy
{
    [Space(20)] 
    [Header("-== EXTRA RANGED ATTRIBUTES ==-")] 
    
    [Space(20)] 
    [Header("-== RANGED ATTACK PROPERTIES ==-")]
    [SerializeField] private float extraAttackRange;
    private bool isLoaded = false;
    [SerializeField] private GameObject bulletPrefab;
    [SerializeField] private Transform spawnPoint;

    [Space(20)] [Header("-== RELOAD PROPERTIES ==-")] 
    [SerializeField] private float reloadTime;
    
    [Space(20)] 
    [Header("-== DETECTION PROPERTIES ==-")]
    [SerializeField] private string animationPrefix;
    [SerializeField] private float detectTime;

    [Space(20)] [Header("-== SCARED PROPERTIES ==-")] 
    [SerializeField] private float searchRange = 30;
    [SerializeField] private float scaredRange;
    [SerializeField] private float timeScared;
    private bool canGetScared = true;
    private float currentScare = 0f;

    public enum RangedEnemyStates
    {
        IDLE,
        DETECT,
        CHASE,
        PATHFIND,
        SHOOT,
        RELOAD,
        FLEE,
        SCARED,
        DIE
    }
    
    private EventFSM<RangedEnemyStates> fsm;

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
        _exitPF = () => { SendInputToFSM(RangedEnemyStates.IDLE);};
        rb.isKinematic = false;
        DoFaceTransition(FaceID.IDLE);
        StopRagdoll();
    }

    void DoFsmSetup()
    {
        #region SETUP

        var idle = new State<RangedEnemyStates>("IDLE");
        var detect = new State<RangedEnemyStates>("DETECT");
        var chasing = new State<RangedEnemyStates>("CHASING");
        var pathfind = new State<RangedEnemyStates>("PATHFIND");
        var shoot = new State<RangedEnemyStates>("SHOOT");
        var reload = new State<RangedEnemyStates>("RELOAD");
        var flee = new State<RangedEnemyStates>("FLEE");
        var scared = new State<RangedEnemyStates>("SCARED");
        var die = new State<RangedEnemyStates>("DIE");

        StateConfigurer.Create(idle)
            .SetTransition(RangedEnemyStates.DETECT, detect)
            .SetTransition(RangedEnemyStates.SHOOT, shoot)
            .SetTransition(RangedEnemyStates.SCARED, scared)
            .SetTransition(RangedEnemyStates.CHASE, chasing)
            .SetTransition(RangedEnemyStates.DIE, die)
            .Done();

        StateConfigurer.Create(detect)
            .SetTransition(RangedEnemyStates.CHASE, chasing)
            .SetTransition(RangedEnemyStates.SHOOT, shoot)
            .SetTransition(RangedEnemyStates.SCARED, scared)
            .SetTransition(RangedEnemyStates.DIE, die)
            .Done();

        StateConfigurer.Create(chasing)
            .SetTransition(RangedEnemyStates.SHOOT, shoot)
            .SetTransition(RangedEnemyStates.SCARED, scared)
            .SetTransition(RangedEnemyStates.PATHFIND, pathfind)
            .SetTransition(RangedEnemyStates.DIE, die)
            .Done();

        StateConfigurer.Create(pathfind)
            .SetTransition(RangedEnemyStates.CHASE, chasing)
            .SetTransition(RangedEnemyStates.SHOOT, shoot)
            .SetTransition(RangedEnemyStates.DIE, die)
            .Done();

        StateConfigurer.Create(shoot)
            .SetTransition(RangedEnemyStates.RELOAD, reload)
            .SetTransition(RangedEnemyStates.SCARED, scared)
            .SetTransition(RangedEnemyStates.CHASE, chasing)
            .SetTransition(RangedEnemyStates.DIE, die)
            .Done();
        
        StateConfigurer.Create(reload)
            .SetTransition(RangedEnemyStates.SHOOT, shoot)
            .SetTransition(RangedEnemyStates.SCARED, scared)
            .SetTransition(RangedEnemyStates.CHASE, chasing)
            .SetTransition(RangedEnemyStates.DIE, die)
            .Done();
        
        StateConfigurer.Create(flee)
            .SetTransition(RangedEnemyStates.SCARED, scared)
            .SetTransition(RangedEnemyStates.CHASE, chasing)
            .SetTransition(RangedEnemyStates.DIE, die)
            .Done();

        StateConfigurer.Create(scared)
            .SetTransition(RangedEnemyStates.FLEE, flee)
            .SetTransition(RangedEnemyStates.IDLE, idle)
            .SetTransition(RangedEnemyStates.CHASE, chasing)
            .SetTransition(RangedEnemyStates.DIE, die)
            .Done();

        StateConfigurer.Create(die).Done();

        #endregion

        #region IDLE

        idle.OnUpdate += () =>
        {
            if (isDead)
            {
                SendInputToFSM(RangedEnemyStates.DIE);
                return;
            }

            if (!IsInFieldOfView()) return;

            if (!wasDetected)
            {
                SendInputToFSM(RangedEnemyStates.DETECT);
                wasDetected = true;
                return;
            }

            if (InDanger() && canGetScared)
            {
                SendInputToFSM(RangedEnemyStates.SCARED);
                return;
            }
            
            if (IsInDistance() && InSight(fovTransformPoint.position, transform.position))
            {
                isAttacking = true;
                SendInputToFSM(RangedEnemyStates.SHOOT);
                return;
            }

            SendInputToFSM(RangedEnemyStates.CHASE);
        };

        #endregion

        #region DETECT

        detect.OnEnter += x =>
        {
            animator.Play(animationPrefix + "_Detect");
            DoFaceTransition(FaceID.DETECT);
            StartCoroutine(DoDetectSign());
            EventManager.Trigger("OnFirstDetection");
            
            //PlayRandomDetectGreet();
        };
        
        detect.OnUpdate += () =>
        {
            transform.LookAt(
                new Vector3(target.transform.position.x, transform.position.y, target.transform.position.z));
            
            //Debug.Log("DETECT");
        };

        detect.OnExit += x =>
        {
            DoFaceTransition(FaceID.COMBAT);
        };

        #endregion

        #region CHASING

        chasing.OnUpdate += () =>
        {
            //Debug.Log("CHASING");
            if (isDead)
            {
                SendInputToFSM(RangedEnemyStates.DIE);
                return;
            }

            if (InDanger() && canGetScared)
            {
                SendInputToFSM(RangedEnemyStates.SCARED);
                return;
            }
           
            if (!InSight(transform.position, target.transform.position, Vector3.down * .5f))
            {
                SendInputToFSM(RangedEnemyStates.PATHFIND);
                return;
            }
            
            if (IsInDistance())
            {
                SendInputToFSM(RangedEnemyStates.SHOOT);
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
            
            isPathfinding = true;
        };

        pathfind.OnUpdate += () =>
        {
            //Debug.Log("PF");
            if (isDead)
            {
                SendInputToFSM(RangedEnemyStates.DIE);
                return;
            }

            if (InDanger() && canGetScared)
            {
                SendInputToFSM(RangedEnemyStates.SCARED);
                return;
            }
            
            if (IsInDistance() && InSight(fovTransformPoint.position, transform.position))
            {
                SendInputToFSM(RangedEnemyStates.SHOOT);
                return;
            }

            if (InSight(transform.position, target.transform.position, Vector3.down * .5f))
            {
                SendInputToFSM(RangedEnemyStates.CHASE);
                return;
            }

            if (isPathfinding && !_waitingPF)
            {
                Debug.Log("PF2");
                SetSpeedValue(Time.deltaTime);
                DoPathfinding();
            }
            else StopSpeed();
        };

        pathfind.OnEnter += x =>
        {
            isPathfinding = false;
        };

        #endregion

        #region SHOOT

        shoot.OnUpdate += () =>
        {
            //Debug.Log("SHOOT");
            if (isDead)
            {
                SendInputToFSM(RangedEnemyStates.DIE);
                return;
            }
            
            if (InDanger() && canGetScared)
            {
                SendInputToFSM(RangedEnemyStates.SCARED);
                return;
            }

            if (!IsInDistance() && !isAttacking)
            {
                SendInputToFSM(RangedEnemyStates.CHASE);
                return;
            }

            if (!isLoaded)
            {
                SendInputToFSM(RangedEnemyStates.RELOAD);
            }
            
            Attack();
        };

        #endregion
        
        #region RELOAD

        reload.OnEnter += x =>
        {
            StopCoroutine(ReloadTimer());
            StartCoroutine(ReloadTimer());
        };

        reload.OnUpdate += () =>
        {
            //Debug.Log("RELOAD");
            if (isDead)
            {
                SendInputToFSM(RangedEnemyStates.DIE);
                return;
            }
            
            if (InDanger() && canGetScared)
            {
                SendInputToFSM(RangedEnemyStates.SCARED);
                return;
            }

            if (!IsInDistance() && !isAttacking)
            {
                SendInputToFSM(RangedEnemyStates.CHASE);
                return;
            }

            if (isLoaded)
            {
                SendInputToFSM(RangedEnemyStates.SHOOT);
            }
        };

        reload.OnExit += x =>
        {
            StopCoroutine(ReloadTimer());
        };

        #endregion

        #region SCARED

        scared.OnEnter += x =>
        {
            if(!canGetScared) SendInputToFSM(RangedEnemyStates.CHASE);
            
            DoWarningFadeOut();
            CalculatePathPreview(true);

            // if (nodeList.PathCount() <= 0)
            // {
            //     SendInputToFSM(RangedEnemyStates.CHASE);
            //     canGetScared = false;
            //     return;
            // }
            
            isPathfinding = true;
            currentScare = timeScared;
            animator.Play("ScaredMovement");
        };

        scared.OnUpdate += () =>
        {
            //Debug.Log("SCARED");
            if (isDead)
            {
                SendInputToFSM(RangedEnemyStates.DIE);
                return;
            }

            if (_waitingPF) return;
            
            currentScare -= Time.deltaTime;

            if (!InDanger() && currentScare <= 0)
            {
                SendInputToFSM(RangedEnemyStates.CHASE);
                return;
            }

            SetSpeedValue(Time.deltaTime);
            DoPathfinding();
        };

        scared.OnExit += x =>
        {
            isPathfinding = false;
            animator.Play("Movement");
        };

        #endregion
        
        #region DEAD

        die.OnEnter += x =>
        {
            DoWarningFadeOut();
            SoundManager.instance.PlaySound(SoundID.ENEMY_GENERIC_DEATH);
            DoFaceTransition(FaceID.DEAD);
        };

        #endregion

        fsm = new EventFSM<RangedEnemyStates>(idle);
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


    private void SendInputToFSM(RangedEnemyStates state)
    {
        fsm.SendInput(state);
    }

    IEnumerator ReloadTimer()
    {
        animator.Play(animationPrefix + "_Pickup");
        yield return new WaitForSeconds(reloadTime);
        isLoaded = true;
        yield return null;
    }
    
    public override void Attack()
    {
        transform.LookAt(new Vector3(target.transform.position.x, transform.position.y, target.transform.position.z));

        if (currentAttackCooldown > 0) return;
        
        currentAttackCooldown = attackCooldown;
        StopSpeed();
        animator.Play(animationPrefix + "_Throw");
    }

    public void SpawnBullet()
    {
        GameObject bullet = Instantiate(bulletPrefab);
        bullet.transform.position = spawnPoint.position;
        bullet.transform.forward = (target.transform.position + (Vector3.up / 3)) - spawnPoint.position;
        //bullet.GetComponent<RangedBullet>()?.OnBulletSpawn();
    }

    public void OnShotOver()
    {
        isLoaded = false;
    }

    public override void Move()
    {
        throw new System.NotImplementedException();
    }

    public override void SetDetection()
    {
        if (wasDetected) return;

        DoFaceTransition(FaceID.COMBAT);
        wasDetected = true;
        SendInputToFSM(RangedEnemyStates.CHASE);
    }

    public override void Death()
    {
        if (isDead) return;
        
        DoWarningFadeOut();
        
        EventManager.Trigger("OnDamageableHit", 3);

        DoRagdoll();
        StartCoroutine(FreezeAllRigidbodies());
        isDead = true;
    }

    public override void DoKnockback()
    {
        animator.Play(animationPrefix + "_Knockback");
    }

    public bool InDanger()
    {
        return Vector3.Distance(transform.position, target.transform.position) <= scaredRange;
    }
    
    public void DoWarningFadeIn()
    {
        LeanTween.cancel(gameObject);
        
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
        LeanTween.cancel(gameObject);
        
        isAttacking = false;
        foreach (var renderer in renderers)
        {
            LeanTween.value(1, 0, 0.3f).setOnUpdate((float value) =>
            {
                renderer.material.SetFloat("_ValueWarning", value);
            });
        }
    }
    
    IEnumerator DoDetectSign()
    {
        yield return new WaitForSeconds(detectTime);

        SendInputToFSM(RangedEnemyStates.CHASE);
        yield return null;
    }
    
    public void PlayRandomDetectGreet()
    {
        int rand = UnityEngine.Random.Range(0, audioDetectIDs.Count);
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
}
