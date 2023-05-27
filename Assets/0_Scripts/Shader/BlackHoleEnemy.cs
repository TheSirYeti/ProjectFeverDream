using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlackHoleEnemy : GenericObject
{
    [SerializeField] private Material _blackHole;
    [SerializeField] private Transform _pos;

    [Range(0.0f, 10.0f)]
    [SerializeField] private float _range;
    [Range(0.0f, 10.0f)]
    [SerializeField] private float _effect;

    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }
    
    public override void OnStart()
    {
        _blackHole.SetVector("_BlackHolePosition", _pos.position);
        _blackHole.SetFloat("_Effect", _effect);
        _blackHole.SetFloat("_Range", _range);
    }

    public override void OnUpdate()
    {
        _blackHole.SetVector("_BlackHolePosition", _pos.position);
        _blackHole.SetFloat("_Effect", _effect);
        _blackHole.SetFloat("_Range", _range);
    }
}
