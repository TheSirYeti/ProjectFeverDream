using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BlackHoleEnemy : MonoBehaviour
{
    [SerializeField] private Material _blackHole;
    [SerializeField] private Transform _pos;

    [Range(0.0f, 10.0f)]
    [SerializeField] private float _range;
    [Range(0.0f, 10.0f)]
    [SerializeField] private float _effect;

    void Start()
    {
        _blackHole.SetVector("_BlackHolePosition", _pos.position);
        _blackHole.SetFloat("_Effect", _effect);
        _blackHole.SetFloat("_Range", _range);
    }

    void Update()
    {
        _blackHole.SetVector("_BlackHolePosition", _pos.position);
        _blackHole.SetFloat("_Effect", _effect);
        _blackHole.SetFloat("_Range", _range);
    }
}
