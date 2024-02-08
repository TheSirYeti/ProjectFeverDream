using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.PlayerLoop;

public class RecipeBillboard : GenericObject
{
    [SerializeField] private List<Recipe> _recipes;
    [SerializeField] private List<GameObject> _recipeImages;
    [Space(15)]
    [SerializeField] private TextMeshPro _recipeTitleText, _recipeInstructionsText;
    
    private int _currentBillboard = -1;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
        
        EventManager.Subscribe("OnNextRecipe", DisplayNextRecipe);
        EventManager.Subscribe("OnPlateFinished", ClearCurrentRecipe);
    }

    public void DisplayNextRecipe(object[] parameters)
    {
        _currentBillboard++;

        if (_currentBillboard >= _recipes.Count)
        {
            _recipeTitleText.text = "";
            _recipeInstructionsText.text = "";

            return;
        }
        _recipeTitleText.text = _recipes[_currentBillboard].recipeName;
        
        foreach (var img in _recipeImages)
        {
            img.SetActive(false);
        }
        _recipeImages[_currentBillboard].SetActive(true);
        
        _recipeInstructionsText.text = "";
        foreach (var instruction in _recipes[_currentBillboard].recipeInstructions)
        {
            _recipeInstructionsText.text += instruction;
            _recipeInstructionsText.text += "<br>";
        }
    }

    void ClearCurrentRecipe(object[] parameters)
    {
        _recipeTitleText.text = "";
        _recipeInstructionsText.text = "";
        
        foreach (var img in _recipeImages)
        {
            img.SetActive(false);
        }
    }
}

[Serializable]
public class Recipe
{
    public string recipeName;
    public List<string> recipeIngredients;
    public List<string> recipeInstructions;
}
