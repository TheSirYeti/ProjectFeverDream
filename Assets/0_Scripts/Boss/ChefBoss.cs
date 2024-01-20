using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using UnityEngine;
using UnityEngine.ProBuilder.MeshOperations;
using Random = System.Random;

public class ChefBoss : GenericObject
{
    #region BOSS STATS

    [Header("Boss Stats")] [SerializeField]
    private int _totalHitPoints;

    #endregion

    #region ATTACK PROPERTIES

    [Space(10)]
    [Header("Attack Properties")]

    #region RANGED ATTACK

    [Header("Ranged Attack")]
    [SerializeField]
    private List<GameObject> _rangedPatterns;

    [SerializeField] private float _rangedAttackRate;
    [SerializeField] private int _rangedAttackAmount;
    [SerializeField] private Transform _rangedAttackSpawnpoint;

    #endregion

    #region SPOTLIGHT ATTACK

    [Header("Spotlight Attack")] [SerializeField]
    private GameObject _spotlight;

    [SerializeField] private List<GameObject> _allLights;
    [SerializeField] private float _spotlightTimer;

    #endregion

    #region GIANT SPATULA ATTACK

    [Header("Giant Spatula Attack")] [SerializeField]
    private GameObject _spatulaPrefab;

    [SerializeField] private string _spatulaBuildUpAnimationName, _spatulaImpactAnimationName;
    [SerializeField] private Animator _spatulaAnimator;
    [SerializeField] private int _spatulaAttackAmount;
    [SerializeField] private float _spatulaAddedDistance;

    #endregion

    #region SHUFFLE ATTACK

    [Header("Shuffle Attack")] [SerializeField]
    private float _shufflePrepareTime, _shuffleChooseTime;

    [SerializeField] private int _shuffleItemAmount;
    [SerializeField] private int _shuffleAmount;
    [SerializeField] private float _shuffleTimeBetweenPlates;
    [SerializeField] private GameObject _shuffleItem, _shufflePunishItem;
    [SerializeField] private List<Transform> _shuffleSpawnpoints;

    #endregion

    #region RAIN ATTACK

    [Header("Rain Attack")] [SerializeField]
    private List<GameObject> _allPatterns;

    [SerializeField] private int _rainAttackAmount;
    [SerializeField] private float _rainTimeBetweenAttacks;

    #endregion

    #region MODIFIERS

    [Space(20)]
    [Header("________________________________________")]
    [Header("Boss Modifiers (After taking Damage)")]
    [Range(0, 1)]
    [SerializeField]
    private float _modRangedAttackRate;

    [Range(0, 5)] [SerializeField] private int _modRangedAttackAmount;
    [Range(0, 5)] [SerializeField] private float _modSpotlightTimer;
    [Range(0, 3)] [SerializeField] private int _modSpatulaAttackAmount;
    [Range(0, 1)] [SerializeField] private int _modShuffleItemAmount;
    [Range(0, 5)] [SerializeField] private int _modShuffleAmount;
    [Range(0, 0.1f)] [SerializeField] private float _modShuffleTimeBetweenPlates;
    [Range(0, 3)] [SerializeField] private int _modRainAttackAmount;
    [Range(0, 2)] [SerializeField] private float _modRainTimeBetweenAttacks;

    #endregion

    private List<IEnumerator> _allAttackCoroutines;
    private List<int> availableAttacks;
    
    private int _currentAttackAmount = 0;
    private int _totalAttackAmount = 3;
    
    private float _currentTimeBetweenWaves = 0;
    private float _currentTimeBetweenAttacks = 0;
    private float _timeBetweenAttacks = 10f;
    private float _timeBetweenWaves = 5f;

    private float _currentTimeTakeDamage = 0f;
    private float _timeTakeDamage = 5f;
    
    private bool attackDone = false;
    private bool waveDone = false;

    #endregion

    #region FSM PROPERTIES

    private bool wasAttacked = false;

    #endregion

    #region FSM

    public enum ChefStates
    {
        IDLE,
        ATTACKING,
        TAKE_DAMAGE,
        DIE
    }

    private EventFSM<ChefStates> _fsm;

    #endregion
    
    private Model _playerRef;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);

        _playerRef = GameManager.Instance.Player;
    }

    public override void OnStart()
    {
        SetupAttackCoroutines();
        SetupFSM();
        SendInputToFSM(ChefStates.IDLE);
    }

    public override void OnUpdate()
    {
        _fsm.Update();
    }

    void SetupFSM()
    {
        #region STATE CONFIGURATION

        var idle = new State<ChefStates>("IDLE");
        var attacking = new State<ChefStates>("ATTACKING");
        var take_damage = new State<ChefStates>("TAKE_DAMAGE");
        var die = new State<ChefStates>("DIE");
        
        StateConfigurer.Create(idle)
            .SetTransition(ChefStates.DIE, die)
            .SetTransition(ChefStates.ATTACKING, attacking)
            .SetTransition(ChefStates.TAKE_DAMAGE, take_damage)
            .Done();
        
        StateConfigurer.Create(attacking)
            .SetTransition(ChefStates.DIE, die)
            .SetTransition(ChefStates.IDLE, idle)
            .SetTransition(ChefStates.TAKE_DAMAGE, take_damage)
            .Done();
        
        StateConfigurer.Create(take_damage)
            .SetTransition(ChefStates.DIE, die)
            .SetTransition(ChefStates.ATTACKING, attacking)
            .SetTransition(ChefStates.IDLE, idle)
            .Done();
        
        StateConfigurer.Create(die)
            .Done();

        #endregion
        
        #region LOGIC

        #region IDLE

        idle.OnEnter += x =>
        {
            if (wasAttacked)
            {
                SendInputToFSM(ChefStates.ATTACKING);
                return;
            }
            
            _currentTimeBetweenWaves = 0f;
        };

        idle.OnUpdate += () =>
        {
            _currentTimeBetweenWaves += Time.deltaTime;
            
            if (_currentTimeBetweenWaves >= _timeBetweenWaves)
            {
                Debug.Log("A ATACKE");
                SendInputToFSM(ChefStates.ATTACKING);
                return;
            }

            if (wasAttacked)
            {
                SendInputToFSM(ChefStates.TAKE_DAMAGE);
                return;
            }
        };

        #endregion

        #region ATTACKING

        attacking.OnEnter += x =>
        {
            attackDone = true;
            waveDone = false;
            
            _currentAttackAmount = -1;
            _currentTimeBetweenAttacks = 999f;
            
            SetAttackOrder();
        };

        attacking.OnUpdate += () =>
        {
            if (wasAttacked)
            {
                SendInputToFSM(ChefStates.TAKE_DAMAGE);
                return;
            }

            if (waveDone)
            {
                BuffAttacks();
                SendInputToFSM(ChefStates.IDLE);
                return;
            }

            if (!attackDone) return;
            
            _currentTimeBetweenAttacks += Time.deltaTime;
            if (_currentTimeBetweenAttacks > _timeBetweenAttacks)
            {
                _currentTimeBetweenAttacks = 0f;
                _currentAttackAmount++;
                attackDone = false;

                if (_currentAttackAmount >= _totalAttackAmount)
                {
                    waveDone = true;
                }
                else
                {
                    Debug.Log("EIEIEIE");
                    DoAttack(availableAttacks[_currentAttackAmount]);
                }
            }
        };

        take_damage.OnEnter += x =>
        {
            _totalHitPoints--;
            if (_totalHitPoints <= 0)
            {
                SendInputToFSM(ChefStates.DIE);
                return;
            }

            _currentTimeTakeDamage = 0f;
            BuffAttacks();
        };

        take_damage.OnUpdate += () =>
        {
            _currentTimeTakeDamage += Time.deltaTime;
            if (_currentTimeTakeDamage >= _timeTakeDamage)
            {
                SendInputToFSM(ChefStates.ATTACKING);
                return;
            }
        };
        
        #endregion

        _fsm = new EventFSM<ChefStates>(idle);
        
        #endregion
    }

    void SendInputToFSM(ChefStates state)
    {
        _fsm.SendInput(state);
    }
    
    void SetupAttackCoroutines()
    {
        _allAttackCoroutines = new List<IEnumerator>();
        
        _allAttackCoroutines.Add(DoRangedPatternAttack());
        _allAttackCoroutines.Add(DoShuffleAttack());
        _allAttackCoroutines.Add(DoGiantSpatulaSplat());
        _allAttackCoroutines.Add(DoPlayerSpotlight());
        _allAttackCoroutines.Add(DoRainPattern());
    }
    
    private void SetAttackOrder()
    {
        List<int> tempAvailableAttacks = new List<int>();
        availableAttacks = new List<int>();

        for (int i = 0; i < _totalAttackAmount; i++)
        {
            tempAvailableAttacks.Add(i);
        }

        for (int i = 0; i < _totalAttackAmount; i++)
        {
            int rand = UnityEngine.Random.Range(0, _totalAttackAmount);

            while (availableAttacks.Contains(rand))
            {
                rand = UnityEngine.Random.Range(0, _totalAttackAmount);
            }
            availableAttacks.Add(rand);
        }

        string temp = "|";
        for (int i = 0; i < _totalAttackAmount; i++)
        {
            temp += availableAttacks[i] + "|";
        }

        Debug.Log(temp);
    }

    void DoAttack(int attackID)
    {
        switch (attackID)
        {
            case 0:
                StopCoroutine(DoRangedPatternAttack());
                StartCoroutine(DoRangedPatternAttack());
                break;
            case 1:
                StopCoroutine(DoShuffleAttack());
                StartCoroutine(DoShuffleAttack());
                break;
            case 2:
                StopCoroutine(DoGiantSpatulaSplat());
                StartCoroutine(DoGiantSpatulaSplat());
                break;
            case 3:
                StopCoroutine(DoPlayerSpotlight());
                StartCoroutine(DoPlayerSpotlight());
                break;
            case 4:
                StopCoroutine(DoRainPattern());
                StartCoroutine(DoRainPattern());
                break;
            default:
                StopCoroutine(DoRangedPatternAttack());
                StartCoroutine(DoRangedPatternAttack());
                break;
        }
    }
    
    #region CHEF ATTACKS
    
    IEnumerator DoRangedPatternAttack()
    {
        Debug.Log("Ranged pattern");
        for (int i = 0; i < _rangedAttackAmount; i++)
        {
            GameObject bullet = Instantiate(_rangedPatterns[UnityEngine.Random.Range(0, _rangedPatterns.Count)]);
            bullet.transform.position = _rangedAttackSpawnpoint.position;
            bullet.transform.LookAt(_playerRef.transform.position + new Vector3(0, 0.5f, 0));
            yield return new WaitForSeconds(_rangedAttackRate);
        }

        attackDone = true;
        yield return null;
    }

    IEnumerator DoPlayerSpotlight()
    {
        Debug.Log("Spotlight pattern");
        float currentTimer = 0f;
        
        foreach (var light in _allLights)
        {
            light.SetActive(false);
        }
        
        _spotlight.SetActive(true);
        while (currentTimer <= _spotlightTimer)
        {
            currentTimer += Time.deltaTime;
            _spotlight.transform.position = _playerRef.transform.position + new Vector3(0, 3f, 0);
            yield return new WaitForSeconds(Time.deltaTime);
        }
        
        foreach (var light in _allLights)
        {
            light.SetActive(true);
        }
        
        _spotlight.SetActive(false);

        attackDone = true;
        yield return null;
    }

    IEnumerator DoGiantSpatulaSplat()
    {
        Debug.Log("Spatyula");
        for (int i = 0; i < _spatulaAttackAmount; i++)
        {
            GameObject spatula = Instantiate(_spatulaPrefab);
            spatula.transform.position = _playerRef.transform.position + new Vector3(0, -1f, _spatulaAddedDistance);
            
            if (spatula.TryGetComponent<Animator>(out Animator spatulaInstanceAnimator))
            {
                spatulaInstanceAnimator.Play(_spatulaBuildUpAnimationName);
                yield return new WaitForEndOfFrame();
                float currentTimer = 0f;
                float animationTime = spatulaInstanceAnimator.GetCurrentAnimatorClipInfo(0)[0].clip.length - 0.5f;
                while (currentTimer <= animationTime)
                {
                    currentTimer += Time.deltaTime;
                    spatula.transform.position = _playerRef.transform.position + new Vector3(0, -1f, _spatulaAddedDistance);
                    yield return new WaitForSeconds(Time.deltaTime);
                }
            
                yield return new WaitForSeconds(0.5f);
                spatulaInstanceAnimator.Play(_spatulaImpactAnimationName);
                yield return new WaitForSeconds(spatulaInstanceAnimator.GetCurrentAnimatorClipInfo(0)[0].clip.length + 0.25f);
            }
        
            Destroy(spatula);
        
            yield return null;
        }

        attackDone = true;
        yield return null;
    }

    IEnumerator DoShuffleAttack()
    {
        Debug.Log("Shuffle");
        List<ShuffleSurprise> allShuffles = new List<ShuffleSurprise>();

        #region Shuffling

        int randGoodItem = UnityEngine.Random.Range(0, _shuffleItemAmount);
        
        for (int i = 0; i < _shuffleItemAmount; i++)
        {
            GameObject item;

            item = Instantiate(_shuffleItem);
            if (i == randGoodItem)
            {
                item.GetComponent<ShuffleSurprise>().SetGoodPlate();
            }

            item.transform.position = _shuffleSpawnpoints[i].position;
            
            allShuffles.Add(item.GetComponent<ShuffleSurprise>());
        }

        yield return new WaitForSeconds(_shufflePrepareTime);

        foreach (var surprise in allShuffles)
        {
            surprise.Open();
        }
        yield return new WaitForSeconds(2.5f);
        
        foreach (var surprise in allShuffles)
        {
            surprise.Close();
        }
        yield return new WaitForSeconds(1.2f);

        for (int i = 0; i < _shuffleAmount; i++)
        {
            int randSurprise1 = UnityEngine.Random.Range(0, _shuffleItemAmount);
            int randSurprise2 = UnityEngine.Random.Range(0, _shuffleItemAmount);

            while (randSurprise2 == randSurprise1)
            {
                randSurprise2 = UnityEngine.Random.Range(0, _shuffleItemAmount);
            }

            Vector3 tempMidPos1 = (allShuffles[randSurprise1].transform.position + allShuffles[randSurprise2].transform.position) / 2f
                                    + new Vector3(0, 0, -1.5f);
            
            Vector3 tempMidPos2 = (allShuffles[randSurprise1].transform.position + allShuffles[randSurprise2].transform.position) / 2f
                                  + new Vector3(0, 0, 1.5f);

            Vector3 tempFinalPos1 = allShuffles[randSurprise1].transform.position;
            Vector3 tempFinalPos2 = allShuffles[randSurprise2].transform.position;

            LeanTween.move(allShuffles[randSurprise1].gameObject, tempMidPos1, _shuffleTimeBetweenPlates / 2f);
            LeanTween.move(allShuffles[randSurprise2].gameObject, tempMidPos2, _shuffleTimeBetweenPlates / 2f);

            yield return new WaitForSeconds(_shuffleTimeBetweenPlates / 2f);
            
            LeanTween.move(allShuffles[randSurprise1].gameObject, 
                tempFinalPos2, _shuffleTimeBetweenPlates / 2f);
            LeanTween.move(allShuffles[randSurprise2].gameObject, 
                tempFinalPos1, _shuffleTimeBetweenPlates / 2f);
            
            yield return new WaitForSeconds(_shuffleTimeBetweenPlates / 2f);
            
            yield return new WaitForSeconds(0.25f);

        }

        #endregion

        foreach (var item in allShuffles)
        {
            item.SetShufflingStatus(false);
        }
        yield return null;

        float currentTimer = 0f;
        bool flag = false;
        while (currentTimer <= _shuffleChooseTime && !flag)
        {
            foreach (var item in allShuffles)
            {
                if (!item.CanInteract())
                {
                    flag = true;
                }
            }
            
            currentTimer += Time.deltaTime;
            Debug.Log("TIMEEE " + currentTimer);
            yield return new WaitForEndOfFrame();
        }
        foreach (var item in allShuffles)
        {
            item.SetShufflingStatus(true);
        }
        GameManager.Instance.Assistant.ResetGeorge();

        yield return new WaitForSeconds(2f);
        if (!flag)
        {
            //sfx no elegiste
            
            GameObject trap = Instantiate(_shufflePunishItem);
            trap.transform.position = GameManager.Instance.Player.transform.position + new Vector3(0, 45f, 0);
            yield return new WaitForSeconds(1f);
        }

        foreach (var item in allShuffles)
        {
            item.DestroyPlate();
        }

        attackDone = true;
        yield return null;
    }

    IEnumerator DoRainPattern()
    {
        Debug.Log("Rain pattern");
        for (int i = 0; i <= _rainAttackAmount; i++)
        {
            int rand = UnityEngine.Random.Range(0, _allPatterns.Count);

            GameObject currentPattern = _allPatterns[rand];

            foreach (Transform child in currentPattern.transform)
            {
                Debug.Log("Gol");
                child.gameObject.SetActive(true);
                child.GetComponent<RainModule>().DoDrop();
            }

            yield return new WaitForSeconds(_rainTimeBetweenAttacks);
        }
        
        attackDone = true;
        yield return null;
    }
    
    public void BuffAttacks()
    {
         _rangedAttackRate -= _modRangedAttackRate;
         _rangedAttackAmount += _modRangedAttackAmount;
        _spotlightTimer += _modSpotlightTimer;
        _spatulaAttackAmount += _modSpatulaAttackAmount;
        _shuffleItemAmount += _modShuffleItemAmount;
        _shuffleAmount += _modShuffleAmount;
        _shuffleTimeBetweenPlates -= _modShuffleTimeBetweenPlates;
        _rainAttackAmount += _modRainAttackAmount;
        _rainTimeBetweenAttacks -= _modRainTimeBetweenAttacks;

        _totalAttackAmount++;
    }
    
    #endregion

}
