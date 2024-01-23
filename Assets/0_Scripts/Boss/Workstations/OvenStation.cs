using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class OvenStation : GenericObject, IAssistInteract
{
    private bool _isOccupied = false;
    [Header("Transforms")]
    [SerializeField] private Transform inputPoint;
    [SerializeField] private Transform outputPoint;
    
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

    IEnumerator DoOvenCooking(Ingredient ingredient)
    {
        _isOccupied = true;

        GameObject reference = ingredient.GetOutput();
        float timeToCook = ingredient.GetDuration();
        ingredient.gameObject.SetActive(false);
        SoundManager.instance.PlaySoundByInt(_sfxID, true);
        
        //feedback de que esta horneando
        yield return new WaitForSeconds(timeToCook);
        
        SoundManager.instance.StopSoundByInt(_sfxID);
        SoundManager.instance.PlaySoundByInt(_doneSfxID);
        GameObject finalOutput = Instantiate(reference);
        
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
