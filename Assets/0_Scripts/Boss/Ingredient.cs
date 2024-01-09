using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Ingredient : GenericObject
{
    [SerializeField] private CookingType _cookingType;
    [SerializeField] private float _cookingDuration;
    [SerializeField] private bool _hasOutput;
    [SerializeField] private GameObject _output;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public float GetDuration()
    {
        return _cookingDuration;
    }

    public CookingType GetCookingType()
    {
        return _cookingType;
    }

    public GameObject GetOutput()
    {
        return _output;
    }
}

[Serializable]
public enum CookingType
{
    CHOPPING,
    STOVE,
    FRIER,
    OVEN,
    MIXER,
    PLATE
}
