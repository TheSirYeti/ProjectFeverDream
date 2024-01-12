using System;
using System.Collections;
using System.Collections.Generic;
using System.ComponentModel;
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

    private Model _playerRef;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);

        _playerRef = GameManager.Instance.Player;
    }

    public override void OnStart()
    {
        StartCoroutine(DoRangedPatternAttack());
    }

    IEnumerator DoRangedPatternAttack()
    {
        for (int i = 0; i < _rangedAttackAmount; i++)
        {
            GameObject bullet = Instantiate(_rangedPatterns[UnityEngine.Random.Range(0, _rangedPatterns.Count)]);
            bullet.transform.position = _rangedAttackSpawnpoint.position;
            bullet.transform.LookAt(_playerRef.transform.position + new Vector3(0, 0.5f, 0));
            yield return new WaitForSeconds(_rangedAttackRate);
            yield return null;
        }

        yield return null;
    }
    
    
}

[Serializable]
public class ChefRangedPattern
{
    public List<GameObject> bullets;
    public List<Transform> bulletSpawnpoints;
}
