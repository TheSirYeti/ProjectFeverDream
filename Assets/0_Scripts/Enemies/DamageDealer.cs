using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DamageDealer : GenericObject
{
    [SerializeField] private int _totalDamage;
    [SerializeField] private bool _damageLoop;
    private bool hasDamaged = false;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }
    
    private void OnTriggerEnter(Collider other)
    {
        IPlayerLife playerLife = other.GetComponentInParent<IPlayerLife>();

        if (playerLife != null && (_damageLoop || !hasDamaged))
        {
            hasDamaged = true;
            playerLife.GetDamage(_totalDamage);
        }
    }
}
