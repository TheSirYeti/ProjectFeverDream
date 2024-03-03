using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using JetBrains.Annotations;
using UnityEngine;
using UnityEngine.ProBuilder.MeshOperations;
using Random = System.Random;

public class ChefBoss : GenericObject
{
    #region BOSS STATS

    [Header("Boss Stats")] 
    [SerializeField] private int _totalHitPoints;
    private int _currentRecipe = -1;

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
    
    [SerializeField] private List<float> _rangedAnimationReleaseTime;

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
    [Range(0, 3)] [SerializeField] private int _modEnemyAmountSpawn;

    #endregion

    private List<IEnumerator> _allAttackCoroutines;
    private List<int> availableAttacks;
    
    private int _currentAttackAmount = 0;
    private int _totalAttackAmount = 3;
    
    private float _currentTimeBetweenWaves = 0;
    private float _currentTimeBetweenAttacks = 0;
    private float _timeBetweenAttacks = 15f;
    private float _timeBetweenWaves = 15f;

    private float _currentTimeTakeDamage = 0f;
    private float _timeTakeDamage = 5f;
    
    private bool attackDone = false;
    private bool waveDone = false;

    #endregion

    #region AMBUSH PROPERTIES

    [Header("Ambush Properties")]
    [SerializeField] private List<Transform> _enemySpawnpoints;
    [SerializeField] private List<GameObject> _allEnemyPrefabs;
    [SerializeField] private int totalEnemiesToSpawn;
    private float _currentEnemySpawnTimer = 0f;
    [SerializeField] private float _totalEnemySpawnTimer;
    
    #endregion

    #region VIEW PROPERTIES

    [Space(20)]
    [Header("All Subtitles")] 
    [SerializeField] private SubtitleSet _rangedSubtitleIntro;
    [SerializeField] private List<SubtitleSet> _rangedSubtitleCounts;
    [Space(10)] 
    [SerializeField] private SubtitleSet _shuffleSubtitleIntro;
    [SerializeField] private SubtitleSet _shuffleSubtitleChoose;
    [SerializeField] private SubtitleSet _shuffleSubtitleGood;
    [SerializeField] private SubtitleSet _shuffleSubtitleBad;
    [SerializeField] private SubtitleSet _shuffleSubtitleTime;
    [Space(10)] 
    [SerializeField] private SubtitleSet _spatulaSubtitle;
    [Space(10)] 
    [SerializeField] private SubtitleSet _spotlightSubtitle;
    [Space(10)] 
    [SerializeField] private SubtitleSet _rainSubtitle;
    [Space(10)] 
    [SerializeField] private List<SubtitleSet> _ambushSubtitles;
    [Space(10)] 
    [SerializeField] private List<SubtitleSet> _recipeSubtitles;

    [Space(30)] [Header("Animator")] 
    [SerializeField] private Animator _animator;

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
    private bool _inCutscene = false;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);

        _playerRef = GameManager.Instance.Player;
        
        EventManager.Subscribe("OnPlateFinished", EndCurrentRecipe);
        EventManager.Subscribe("OnNextRecipe", Recover);
    }

    public override void OnStart()
    {
        SetupAttackCoroutines();
        SetupFSM();
        SendInputToFSM(ChefStates.TAKE_DAMAGE);
        
        SoundManager.instance.PlayMusic(MusicID.GAMESHOW, true);
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
            
            _animator.Play("Boss_Dance_04");
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

        int attackRand = 0;
        
        attacking.OnEnter += x =>
        {
            attackDone = true;
            waveDone = false;
            
            _currentAttackAmount = -1;
            _currentTimeBetweenAttacks = 999f;

            _currentEnemySpawnTimer = 0f;
            
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
                SendInputToFSM(ChefStates.IDLE);
                return;
            }
            
            if (!attackDone) return;
            
            _currentTimeBetweenAttacks += Time.deltaTime;
            if (_currentTimeBetweenAttacks > _timeBetweenAttacks)
            {
                _currentTimeBetweenAttacks = 0f;
                
                if (attackRand == 0)
                {
                    DoEnemySpawning();
                    attackRand = 1;
                }
                else
                {
                    _currentAttackAmount++;
                    if (_currentAttackAmount >= _totalAttackAmount)
                    {
                        waveDone = true;
                    }
                    else
                    {
                        DoAttack(availableAttacks[_currentAttackAmount]);
                    }
                    attackDone = false;
                    attackRand = 0;
                }
            }
        };
        
        #endregion

        #region TAKE DAMAGE

        take_damage.OnEnter += x =>
        {
            _inCutscene = true;
            _totalHitPoints--;
            if (_totalHitPoints <= 0)
            {
                SendInputToFSM(ChefStates.DIE);
                return;
            }

            _currentTimeTakeDamage = 0f;
        };

        take_damage.OnUpdate += () =>
        {
            if (!_inCutscene)
            {
                SendInputToFSM(ChefStates.IDLE);
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
        EventManager.Trigger("OnVoicelineSetTriggered", _rangedSubtitleIntro);
        yield return new WaitForSeconds((_rangedSubtitleIntro.allVoicelines[0].duration + 1f));

        if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
        
        Debug.Log("Ranged pattern");
        for (int i = 0; i < _rangedAttackAmount; i++)
        {
            if(_inCutscene) yield break;
            
            int rand = UnityEngine.Random.Range(1, 4);
            _animator.Play("Boss_Throw_0" + rand);
            yield return new WaitForSeconds(_rangedAnimationReleaseTime[rand - 1]);
            
            GameObject bullet = Instantiate(_rangedPatterns[UnityEngine.Random.Range(0, _rangedPatterns.Count)]);
            if(InstanceManager.instance != null)
                bullet.transform.SetParent(InstanceManager.instance.transform);
            bullet.transform.position = _rangedAttackSpawnpoint.position;
            bullet.transform.LookAt(_playerRef.transform.position + new Vector3(0, 0.5f, 0));
            EventManager.Trigger("OnVoicelineSetTriggered", _rangedSubtitleCounts[i]);
            if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
            yield return new WaitForSeconds(_rangedAttackRate);
        }

        attackDone = true;
        _animator.Play("Boss_Dance_0" + UnityEngine.Random.Range(1, 5));
        yield return null;
    }

    IEnumerator DoPlayerSpotlight()
    {
        EventManager.Trigger("OnVoicelineSetTriggered", _spotlightSubtitle);
        yield return new WaitForSeconds((_spotlightSubtitle.allVoicelines[0].duration));
        
        if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
        
        Debug.Log("Spotlight pattern");
        float currentTimer = 0f;
        
        foreach (var light in _allLights)
        {
            light.SetActive(false);
        }
        
        _spotlight.SetActive(true);
        while (currentTimer <= _spotlightTimer)
        {
            if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
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
        EventManager.Trigger("OnVoicelineSetTriggered", _spatulaSubtitle);
        if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
        
        Debug.Log("Spatyula");
        for (int i = 0; i < _spatulaAttackAmount; i++)
        {
            if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
            
            GameObject spatula = Instantiate(_spatulaPrefab);
            if(InstanceManager.instance != null)
                spatula.transform.SetParent(InstanceManager.instance.transform);
            spatula.transform.position = _playerRef.transform.position + new Vector3(0, -1f, _spatulaAddedDistance);
            
            if (spatula.TryGetComponent<Animator>(out Animator spatulaInstanceAnimator))
            {
                if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
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
            
                if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
                yield return new WaitForSeconds(0.5f);
                spatulaInstanceAnimator.Play(_spatulaImpactAnimationName);
                if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
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
        
        if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());

        #region Shuffling

        int randGoodItem = UnityEngine.Random.Range(0, _shuffleItemAmount);
        
        for (int i = 0; i < _shuffleItemAmount; i++)
        {
            GameObject item;

            item = Instantiate(_shuffleItem);
            if(InstanceManager.instance != null)
                item.transform.SetParent(InstanceManager.instance.transform);
            if (i == randGoodItem)
            {
                item.GetComponent<ShuffleSurprise>().SetGoodPlate();
            }

            item.transform.position = _shuffleSpawnpoints[i].position;
            
            allShuffles.Add(item.GetComponent<ShuffleSurprise>());
        }

        EventManager.Trigger("OnVoicelineSetTriggered", _shuffleSubtitleIntro);
        if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
        yield return new WaitForSeconds((_shuffleSubtitleIntro.allVoicelines[0].duration + 0.5f));
        
        //yield return new WaitForSeconds(_shufflePrepareTime);

        foreach (var surprise in allShuffles)
        {
            surprise.Open();
        }
        if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
        yield return new WaitForSeconds(2.5f);
        
        if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
        foreach (var surprise in allShuffles)
        {
            surprise.Close();
        }
        yield return new WaitForSeconds(1.2f);

        if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
        for (int i = 0; i < _shuffleAmount; i++)
        {
            if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
            
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
            
            SoundManager.instance.PlaySound(SoundID.SHUFFLE_WOOSH);
            
            yield return new WaitForSeconds(_shuffleTimeBetweenPlates / 2f);
            
            yield return new WaitForSeconds(0.25f);

        }

        #endregion

        foreach (var item in allShuffles)
        {
            item.SetShufflingStatus(false);
        }
        yield return null;
        
        if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
        
        EventManager.Trigger("OnVoicelineSetTriggered", _shuffleSubtitleChoose);
        yield return new WaitForSeconds((_shuffleSubtitleChoose.allVoicelines[0].duration));

        if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
        
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
            yield return new WaitForEndOfFrame();
        }
        foreach (var item in allShuffles)
        {
            item.SetShufflingStatus(true);
        }
        GameManager.Instance.Assistant.ResetGeorge();

        if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
        
        yield return new WaitForSeconds(2f);
        if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
        
        if (!flag)
        {
            SoundManager.instance.PlaySound(SoundID.SHUFFLE_TIME);
            EventManager.Trigger("OnVoicelineSetTriggered", _shuffleSubtitleTime);
            yield return new WaitForSeconds((_shuffleSubtitleTime.allVoicelines[0].duration + 0.5f));
            GameObject trap = Instantiate(_shufflePunishItem);
            if(InstanceManager.instance != null)
                trap.transform.SetParent(InstanceManager.instance.transform);
            trap.transform.position = GameManager.Instance.Player.transform.position + new Vector3(0, 45f, 0);
            yield return new WaitForSeconds(1.5f);
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
        EventManager.Trigger("OnVoicelineSetTriggered", _rainSubtitle);
        yield return new WaitForSeconds((_rainSubtitle.allVoicelines[0].duration));
        if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
        
        Debug.Log("Rain pattern");
        for (int i = 0; i <= _rainAttackAmount; i++)
        {
            if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
            int rand = UnityEngine.Random.Range(0, _allPatterns.Count);
            GameObject currentPattern = _allPatterns[rand];

            foreach (Transform child in currentPattern.transform)
            {
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
        if (_currentRecipe <= -1) return; 
        
         _rangedAttackRate -= _modRangedAttackRate;
         _rangedAttackAmount += _modRangedAttackAmount;
        _spotlightTimer += _modSpotlightTimer;
        _spatulaAttackAmount += _modSpatulaAttackAmount;
        _shuffleItemAmount += _modShuffleItemAmount;
        _shuffleAmount += _modShuffleAmount;
        _shuffleTimeBetweenPlates -= _modShuffleTimeBetweenPlates;
        _rainAttackAmount += _modRainAttackAmount;
        _rainTimeBetweenAttacks -= _modRainTimeBetweenAttacks;
        totalEnemiesToSpawn += _modEnemyAmountSpawn;
        _timeBetweenAttacks -= 2f;
        _timeBetweenWaves -= 2f;
        
        _totalAttackAmount++;
    }
    
    #endregion

    void DoEnemySpawning()
    {
        int randVoice = UnityEngine.Random.Range(0, _ambushSubtitles.Count);
        EventManager.Trigger("OnVoicelineSetTriggered", _ambushSubtitles[randVoice]);
        
        for (int i = 0; i < totalEnemiesToSpawn; i++)
        {
            int rand = UnityEngine.Random.Range(0, _allEnemyPrefabs.Count);
            GameObject robot = Instantiate(_allEnemyPrefabs[rand]);
            if(InstanceManager.instance != null)
                robot.transform.SetParent(InstanceManager.instance.transform);
            robot.transform.position = _enemySpawnpoints[i].position;
        }
    }
    
    void Recover(object[] parameters)
    {
        StartCoroutine(SetupNextRecipe());
    }
    
    public IEnumerator SetupNextRecipe()
    {
        BuffAttacks();
        
        _currentRecipe++;
        float totalSubsTime = 0f;

        foreach (var voiceline in _recipeSubtitles[_currentRecipe].allVoicelines)
        {
            totalSubsTime += voiceline.duration;
        }
        
        EventManager.Trigger("OnVoicelineSetTriggered", _recipeSubtitles[_currentRecipe]);
        yield return new WaitForSeconds(totalSubsTime);
        
        _inCutscene = false;
        yield return null;
    }

    void EndCurrentRecipe(object[] parameters)
    {
        SendInputToFSM(ChefStates.TAKE_DAMAGE);
    }
}
