using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ChoppingStation : GenericObject, IWorkstation
{
    private bool _isOccupied = false;
    [SerializeField] private Transform outputPoint;
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public void ProcessFood(Ingredient ingredient)
    {
        if (!_isOccupied && ingredient.GetCookingType() == CookingType.CHOPPING) 
            StartCoroutine(DoChopping(ingredient));
    }

    IEnumerator DoChopping(Ingredient ingredient)
    {
        _isOccupied = true;
        
        //feedback de que esta cortando
        yield return new WaitForSeconds(ingredient.GetDuration());
        
        GameObject finalOutput = Instantiate(ingredient.GetOutput());
        ingredient.gameObject.SetActive(false);
        
        finalOutput.transform.position = outputPoint.position;
        _isOccupied = false;
        
        yield return null;
    }
}
