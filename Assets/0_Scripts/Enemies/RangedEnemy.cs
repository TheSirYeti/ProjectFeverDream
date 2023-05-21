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
    
    [Space(20)] 
    [Header("-== SCARED PROPERTIES ==-")] 
    [SerializeField] private float scaredRange;

    [SerializeField] private float timeScared;
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

            if (InDanger())
            {
                SendInputToFSM(RangedEnemyStates.SCARED);
                return;
            }
            
            if (IsInDistance())
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
        };
        
        detect.OnUpdate += () =>
        {
            transform.LookAt(
                new Vector3(target.transform.position.x, transform.position.y, target.transform.position.z));
        };

        detect.OnExit += x =>
        {
            DoFaceTransition(FaceID.COMBAT);
        };

        #endregion

        #region CHASING

        chasing.OnUpdate += () =>
        {
            if (isDead)
            {
                SendInputToFSM(RangedEnemyStates.DIE);
                return;
            }

            if (InDanger())
            {
                SendInputToFSM(RangedEnemyStates.SCARED);
                return;
            }
            
            if (IsInDistance())
            {
                SendInputToFSM(RangedEnemyStates.SHOOT);
                return;
            }

            if (!InSight(transform.position, target.transform.position))
            {
                SendInputToFSM(RangedEnemyStates.PATHFIND);
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
                SendInputToFSM(RangedEnemyStates.DIE);
                return;
            }

            if (InDanger())
            {
                SendInputToFSM(RangedEnemyStates.SCARED);
                return;
            }
            
            if (IsInDistance())
            {
                SendInputToFSM(RangedEnemyStates.SHOOT);
                return;
            }

            if (InSight(transform.position, target.transform.position))
            {
                SendInputToFSM(RangedEnemyStates.CHASE);
                return;
            }

            if (nodePath.Any() || currentNode < nodePath.Count)
            {
                SetSpeedValue(Time.deltaTime);
                DoPathfinding();
            }
            else StopSpeed();
        };

        #endregion

        #region SHOOT

        shoot.OnUpdate += () =>
        {
            if (isDead)
            {
                SendInputToFSM(RangedEnemyStates.DIE);
                return;
            }
            
            if (InDanger())
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
            StartCoroutine(ReloadTimer());
        };

        reload.OnUpdate += () =>
        {
            if (isDead)
            {
                SendInputToFSM(RangedEnemyStates.DIE);
                return;
            }
            
            if (InDanger())
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
            DoWarningFadeOut();
            CalculatePathPreview(true);
            currentScare = timeScared;
            animator.Play("ScaredMovement");
        };

        scared.OnUpdate += () =>
        {
            if (isDead)
            {
                SendInputToFSM(RangedEnemyStates.DIE);
                return;
            }
            
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
            animator.Play("Movement");
        };

        #endregion
        
        #region DEAD

        die.OnEnter += x =>
        {
            DoWarningFadeOut();
            DoFaceTransition(FaceID.DEAD);
        };

        #endregion

        fsm = new EventFSM<RangedEnemyStates>(idle);
    }

    private void Update()
    {
        animator.SetFloat("movementSpeed", speed);
        currentAttackCooldown -= Time.deltaTime;
        pathfindingCooldown -= Time.deltaTime;
        
        fsm.Update();
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
    }

    public void OnShotOver()
    {
        isLoaded = false;
    }

    public override void Move()
    {
        throw new System.NotImplementedException();
    }

    public override void Death()
    {
        if (isDead) return;
        
        DoWarningFadeOut();
        
        EventManager.Trigger("OnDamageableHit", 3);

        DoRagdoll();
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
    
    IEnumerator DoDetectSign()
    {
        yield return new WaitForSeconds(detectTime);

        SendInputToFSM(RangedEnemyStates.CHASE);
        yield return null;
    }
}
