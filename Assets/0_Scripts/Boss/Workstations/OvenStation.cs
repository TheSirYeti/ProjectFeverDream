using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class OvenStation : GenericObject, IAssistInteract
{
    private bool _isOccupied = false;
    [SerializeField] private Transform inputPoint;
    [SerializeField] private Transform outputPoint;
    
    [SerializeField] private Outline outline;
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    IEnumerator DoOvenCooking(Ingredient ingredient)
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
    
    #region Jorge Interface
    
    public void Interact(IAssistInteract usableItem = null)
    {
        if (usableItem != null 
            && !_isOccupied
            && usableItem.GetInteractType() == Interactuables.INGREDIENT)
            StartCoroutine(DoOvenCooking(usableItem as Ingredient));
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
        return "Oven ingredient";
    }

    public void ChangeOutlineState(bool state)
    {
        if (outline == null) return;
        
        outline.enabled = state;
        outline.OutlineWidth = 10;
    }

    public bool CanInteractWith(IAssistInteract assistInteract)
    {
        return assistInteract.GetInteractType() == Interactuables.INGREDIENT &&
               assistInteract is Ingredient ingredient && 
               ingredient.GetCookingType()==CookingType.OVEN;
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
