using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class FryingStation : GenericObject, IAssistInteract
{
    private bool _isOccupied = false;
    [Header("Transforms")]
    [SerializeField] private Transform inputPoint;
    [SerializeField] private Transform outputPoint;
    [SerializeField] private Transform usingPoint;
    
    [Header("View Properties")]
    [SerializeField] private Outline outline;
    [SerializeField] private AudioSource _sfx;
    private int _sfxID;
    [SerializeField] private AudioSource _doneSfx;
    private int _doneSfxID;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }
    
    public override void OnStart()
    {
        _sfxID = SoundManager.instance.AddSFXSource(_sfx);
        _doneSfxID = SoundManager.instance.AddSFXSource(_doneSfx);
    }

    IEnumerator DoFrying(Ingredient ingredient)
    {
        _isOccupied = true;

        if (ingredient is IPickUp pickUp)pickUp.Pickup();

        SoundManager.instance.PlaySoundByInt(_sfxID, true);
        ingredient.transform.position = usingPoint.position;
        
        //feedback de que esta cortando
        yield return new WaitForSeconds(ingredient.GetDuration());
        
        SoundManager.instance.StopSoundByInt(_sfxID);
        SoundManager.instance.PlaySoundByInt(_doneSfxID);
        
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
            StartCoroutine(DoFrying(usableItem as Ingredient));
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
        return "Fry Ingredient";
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
               ingredient.GetCookingType()==CookingType.FRIER;
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
