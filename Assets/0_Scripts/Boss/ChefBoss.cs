using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
using System.Linq;
using UnityEngine;
using Random = System.Random;

public class ChefBoss : GenericObject
{
    [Header("Boss Stats")]
    [SerializeField] private float _totalHitPoints;

    [Space(10)] 
    [Header("Attack Properties")] 
    [Header("Ranged Attack")] 
    [SerializeField] private List<GameObject> _rangedPatterns;
    [SerializeField] private float _rangedAttackRate;
    [SerializeField] private int _rangedAttackAmount;
    [SerializeField] private Transform _rangedAttackSpawnpoint;

    [Header("Spotlight Attack")]
    [SerializeField] private GameObject _spotlight;
    [SerializeField] private List<GameObject> _allLights;
    [SerializeField] private float _spotlightTimer;

    [Header("Giant Spatula Attack")] 
    [SerializeField] private GameObject _spatulaPrefab;
    [SerializeField] private string _spatulaBuildUpAnimationName, _spatulaImpactAnimationName;
    [SerializeField] private Animator _spatulaAnimator;
    [SerializeField] private int _spatulaAttackAmount;
    [SerializeField] private float _spatulaAddedDistance;

    [Header("Shuffle Attack")] 
    [SerializeField] private float _shufflePrepareTime;
    [SerializeField] private int _shuffleItemAmount;
    [SerializeField] private int _shuffleAmount;
    [SerializeField] private float _shuffleTimeBetweenPlates;
    [SerializeField] private GameObject _shuffleGoodItem, _shuffleBadItem;
    [SerializeField] private List<Transform> _shuffleSpawnpoints;
    
    
    private Model _playerRef;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);

        _playerRef = GameManager.Instance.Player;
    }

    public override void OnStart()
    {
        StartCoroutine(DoShuffleAttack());
    }

    IEnumerator DoRangedPatternAttack()
    {
        for (int i = 0; i < _rangedAttackAmount; i++)
        {
            GameObject bullet = Instantiate(_rangedPatterns[UnityEngine.Random.Range(0, _rangedPatterns.Count)]);
            bullet.transform.position = _rangedAttackSpawnpoint.position;
            bullet.transform.LookAt(_playerRef.transform.position + new Vector3(0, 0.5f, 0));
            yield return new WaitForSeconds(_rangedAttackRate);
        }

        yield return null;
    }

    IEnumerator DoPlayerSpotlight()
    {
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
        yield return null;
    }

    IEnumerator DoGiantSpatulaSplat()
    {
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

        yield return null;
    }

    IEnumerator DoShuffleAttack()
    {
        List<ShuffleSurprise> allShuffles = new List<ShuffleSurprise>();
        int randGoodItem = UnityEngine.Random.Range(0, _shuffleItemAmount);
        
        for (int i = 0; i < _shuffleItemAmount; i++)
        {
            GameObject item;

            if (i == randGoodItem)
                item = Instantiate(_shuffleGoodItem);
            else  item = Instantiate(_shuffleBadItem);

            item.transform.position = _shuffleSpawnpoints[i].position;
            
            allShuffles.Add(item.GetComponent<ShuffleSurprise>());
        }

        yield return new WaitForSeconds(_shufflePrepareTime);

        foreach (var surprise in allShuffles)
        {
            surprise.Reveal();
        }
        yield return new WaitForSeconds(2.5f);
        
        foreach (var surprise in allShuffles)
        {
            surprise.Close();
        }
        yield return new WaitForSeconds(1.2f);

        for (int i = 0; i < _shuffleAmount; i++)
        {
            Debug.Log("INICIO TREMENDO");
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
            Debug.Log("FIN TREMENDO");
            yield return new WaitForSeconds(0.25f);

        }
        
        yield return null;
    }
    
}