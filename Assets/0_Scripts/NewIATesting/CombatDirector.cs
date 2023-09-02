using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CombatDirector : GenericObject
{
    private List<Enemy> _attackOrder = new();
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnAwake()
    {
        EventManager.Subscribe("AddEnemyDirector", AddEnemy);
        EventManager.Subscribe("RemoveEnemyDirector", RemoveEnemy);
    }

    private void TriggerAttacker()
    {
        
    }

    private void AddEnemy(params object[] parameters)
    {
        if (_attackOrder.Contains((Enemy)parameters[0])) return;
        
        _attackOrder.Add((Enemy)parameters[0]);

        if (_attackOrder.Count == 1) TriggerAttacker();
    }
    
    private void RemoveEnemy(params object[] parameters)
    {
        if (!_attackOrder.Contains((Enemy)parameters[0])) return;
        
        _attackOrder.Remove((Enemy)parameters[0]);
    }
}
