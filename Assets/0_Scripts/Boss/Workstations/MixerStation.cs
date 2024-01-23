using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class MixerStation : GenericObject, IAssistInteract
{
    private bool _isOccupied = false;
    [Header("Mixer Properties")]
    [SerializeField] private List<IngredientType> _requiredIngredients;
    private List<IngredientType> _currentIngredients = new List<IngredientType>();
    
    [Header("Transforms")]
    [SerializeField] private Ingredient mixingOutput;
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
        
        Debug.Log(_sfxID);
    }

    public void ProcessFood(Ingredient ingredient)
    {
        _currentIngredients.Add(ingredient.GetIngredientType());
        ingredient.gameObject.SetActive(false);

        if (_currentIngredients.Count == _requiredIngredients.Count)
            StartCoroutine(DoMixing(ingredient));
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

        SoundManager.instance.PlaySoundByInt(_sfxID, true);
        //feedback de que esta cortando
        yield return new WaitForSeconds(ingredient.GetDuration());

        SoundManager.instance.StopSoundByInt(_sfxID);
        SoundManager.instance.PlaySoundByInt(_doneSfxID);
        var finalOutput = Instantiate(mixingOutput);

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