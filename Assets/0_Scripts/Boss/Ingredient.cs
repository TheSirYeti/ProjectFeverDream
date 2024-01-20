using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

public class Ingredient : GenericObject, IAssistInteract, IPickUp
{
    [SerializeField] private CookingType _cookingType;
    [SerializeField] private IngredientType _ingredientType;
    [SerializeField] private float _cookingDuration;
    [SerializeField] private bool _hasOutput;
    [SerializeField] private GameObject _output;
    [SerializeField] private Outline _outline;

    private bool _isInteractable = true;

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

    public IngredientType GetIngredientType()
    {
        return _ingredientType;
    }

    public GameObject GetOutput()
    {
        return _output;
    }

    #region Jorge Interact

    public Interactuables GetInteractType()
    {
        return Interactuables.INGREDIENT;
    }

    public Assistant.JorgeStates GetState()
    {
        return Assistant.JorgeStates.PICKUP;
    }

    public Transform GetTransform()
    {
        return transform;
    }

    public Transform GetInteractPoint()
    {
        return transform;
    }
    
    public bool CanInteract()
    {
        return _isInteractable;
    }

    public string ActionName()
    {
        return "PickUp Ingredient";
    }
    public void ChangeOutlineState(bool state)
    {
        if (_outline == null) return;
        
        _outline.enabled = state;
        _outline.OutlineWidth = 10;
    }

    public bool CanInteractWith(IAssistInteract assistInteract)
    {
        throw new NotImplementedException();
    }

    public bool IsAutoUsable()
    {
        return false;
    }

    #endregion

    #region Not Used Methods Interact Interface

    public void Interact(IAssistInteract usableItem = null)
    {
    }
    
    public List<Renderer> GetRenderer()
    {
        throw new NotImplementedException();
    }
    
    public string AnimationToExecute()
    {
        return "";
    }
    
    public Transform GoesToUsablePoint()
    {
        throw new NotImplementedException();
    }

    #endregion

    public void Pickup()
    {
        _isInteractable = false;
    }

    public void UnPickUp()
    {
        transform.parent = null;
        _isInteractable = true;
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

public enum IngredientType
{
    CEBOLLA,
    CEBOLLACORTADA,
    LECHUGA,
    LECHUGACORTADA,
    TOMATE,
    TOMATECORTADO,
    PAN,
    PANCORTADO,
    PAPAS,
    PAPASCORTADAS,
    PAPASFRITAS,
    PATY,
    PATYCOCINADO,
    CHOCOLATE,
    CREMA,
    FRUTILLAS,
    FRUTILLASCORTADAS,
    HARINA,
    HUEVOS,
    LECHE,
    MEZCLATORTA,
    TORTA
}
