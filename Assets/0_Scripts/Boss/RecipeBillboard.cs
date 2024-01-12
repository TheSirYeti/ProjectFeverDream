using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.PlayerLoop;

public class RecipeBillboard : GenericObject
{
    [SerializeField] private List<Recipe> _recipes;
    [Space(15)]
    [SerializeField] private TextMeshPro _recipeTitleText, _recipeIngredientsText, _recipeInstructionsText;
    
    private int _currentBillboard = -1;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
        DisplayNextRecipe();
        DisplayNextRecipe();
        DisplayNextRecipe();
    }

    public void DisplayNextRecipe()
    {
        _currentBillboard++;

        if (_currentBillboard >= _recipes.Count)
        {
            _recipeTitleText.text = "";
            _recipeIngredientsText.text = "";
            _recipeInstructionsText.text = "";

            return;
        }
        _recipeTitleText.text = _recipes[_currentBillboard].recipeName;

        _recipeIngredientsText.text = "";
        foreach (var ingredient in _recipes[_currentBillboard].recipeIngredients)
        {
            _recipeIngredientsText.text += ingredient;
            _recipeIngredientsText.text += "<br>";
        }
        
        _recipeInstructionsText.text = "";
        foreach (var instruction in _recipes[_currentBillboard].recipeInstructions)
        {
            _recipeInstructionsText.text += instruction;
            _recipeInstructionsText.text += "<br>";
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
