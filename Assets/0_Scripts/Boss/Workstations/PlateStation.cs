using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class PlateStation : GenericObject, IAssistInteract
{
    private bool _isOccupied = false;
    [Header("Plate Properties")]
    [SerializeField] private List<IngredientType> _requiredIngredients;
    private List<IngredientType> _currentIngredients = new List<IngredientType>();

    [Header("Cutscene Properties")] 
    [SerializeField] private Transform _plateCutsceneTransform;
    [SerializeField] private Transform _plateStartingPoint;
    [Space(10)] 
    [SerializeField] private int _timelineID;
    
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
    }

    public void ProcessFood(Ingredient ingredient)
    {
        _currentIngredients.Add(ingredient.GetIngredientType());
        ingredient.gameObject.SetActive(false);

        if (_currentIngredients.Count == _requiredIngredients.Count)
            StartCoroutine(MakePresentation(mixingOutput));
    }

    public bool CheckIngredientList(Ingredient ingredient)
    {
        if (_requiredIngredients.Contains(ingredient.GetIngredientType()) && !_currentIngredients.Contains(ingredient.GetIngredientType()))
            return true;
        return false;
    }

    IEnumerator MakePresentation(Ingredient ingredient)
    {
        _isOccupied = true;

        //feedback de que esta cortando
        SoundManager.instance.PlaySoundByInt(_sfxID, true);
        yield return new WaitForSeconds(ingredient.GetDuration());

        var finalOutput = Instantiate(ingredient);
        SoundManager.instance.StopSoundByInt(_sfxID);
        SoundManager.instance.PlaySoundByInt(_doneSfxID);

        finalOutput.transform.position = outputPoint.position;

        _plateCutsceneTransform.gameObject.SetActive(true);

        if (_plateCutsceneTransform.childCount > 0)
        {
            Destroy(_plateCutsceneTransform.GetChild(0).gameObject);
        }
        
        _plateCutsceneTransform.position = _plateStartingPoint.position;
        finalOutput.transform.parent = _plateCutsceneTransform;
        
        CutsceneManager.instance.PlayTimeline(_timelineID);
        
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
        return "add to the Plate";
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
               ingredient.GetCookingType() == CookingType.PLATE;
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