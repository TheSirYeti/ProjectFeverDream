using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor.Rendering;
using UnityEngine;

public class WorkStationManager : GenericObject
{
    [SerializeField] private List<GameObject> _workstationSetups;
    [SerializeField] private GameObject _ingredientPrefab;
    private GameObject _currentIngredients;
    
    private int currentWorkstation = -1;
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
        
        EventManager.Subscribe("OnNextRecipe", SetupWorkstations);
    }

    void SetupWorkstations(object[] parameters)
    {
        foreach (var stations in _workstationSetups)
        {
            stations.SetActive(false);
        }

        currentWorkstation++;
        _workstationSetups[currentWorkstation].SetActive(true);

        if (_currentIngredients != null)
            _currentIngredients.SetActive(false);

        _currentIngredients = Instantiate(_ingredientPrefab);
    }
}
