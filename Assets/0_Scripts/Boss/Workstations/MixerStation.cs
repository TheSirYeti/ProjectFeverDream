using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class MixerStation : GenericObject, IAssistInteract
{
    private bool _isOccupied = false;
    [SerializeField] private List<IngredientType> _requiredIngredients;
    private List<IngredientType> _currentIngredients = new List<IngredientType>();
    [SerializeField] private Ingredient mixingOutput;
    [SerializeField] private Transform inputPoint;
    [SerializeField] private Transform outputPoint;

    [SerializeField] private Outline outline;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public void ProcessFood(Ingredient ingredient)
    {
        _currentIngredients.Add(ingredient.GetIngredientType());
        ingredient.gameObject.SetActive(false);

        if (_currentIngredients.Count == _requiredIngredients.Count)
            StartCoroutine(DoMixing(mixingOutput));
    }

    public bool CheckIngredientList(Ingredient ingredient)
    {
        if (_requiredIngredients.Contains(ingredient.GetIngredientType()) && !_currentIngredients.Contains(ingredient.GetIngredientType()))
            return true;
        return false;
    }

    IEnumerator DoMixing(Ingredient ingredient)
    {
        _isOccupied = true;

        //feedback de que esta cortando
        yield return new WaitForSeconds(ingredient.GetDuration());

        var finalOutput = Instantiate(ingredient);

        finalOutput.transform.position = outputPoint.position;
        _isOccupied = false;

        yield return null;
    }

    #region Jorge Interface

    public void Interact(IAssistInteract usableItem = null)
    {
        if (usableItem != null)
            ProcessFood(usableItem as Ingredient);
    }

    public Interactuables GetInteractType()
    {
        return Interactuables.COOKINGSTATION;
    }

    public Assistant.JorgeStates GetState()
    {
        return Assistant.JorgeStates.USEIT;
    }

    public Transform GetTransform()
    {
        return transform;
    }

    public Transform GetInteractPoint()
    {
        return inputPoint;
    }

    public bool CanInteract()
    {
        return !_isOccupied;
    }

    public string ActionName()
    {
        return "Add Ingredient to the Mixer";
    }

    public void ChangeOutlineState(bool state)
    {
        if (outline == null) return;

        outline.enabled = state;
        outline.OutlineWidth = 10;
    }

    public bool CanInteractWith(IAssistInteract assistInteract)
    {
        return assistInteract is Ingredient ingredient &&
               CheckIngredientList(ingredient) &&
               ingredient.GetCookingType() == CookingType.MIXER;
    }

    public bool IsAutoUsable()
    {
        return false;
    }

    #endregion

    #region Not Used Methods Interact Interface

    public List<Renderer> GetRenderer()
    {
        throw new NotImplementedException();
    }

    public string AnimationToExecute()
    {
        throw new NotImplementedException();
    }

    public Transform GoesToUsablePoint()
    {
        throw new NotImplementedException();
    }

    #endregion
}