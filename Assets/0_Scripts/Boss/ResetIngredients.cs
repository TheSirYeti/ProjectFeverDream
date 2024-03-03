using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ResetIngredients : GenericObject, IAssistInteract
{
    public Transform _interactPoint;
    public List<Renderer> _renderers;
    public Outline _outline;
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }


    public void Interact(IAssistInteract usableItem = null)
    {
        EventManager.Trigger("OnResetIngredients");
    }

    public Interactuables GetInteractType()
    {
        return Interactuables.DOOR;
    }

    public Assistant.JorgeStates GetState()
    {
        return Assistant.JorgeStates.INTERACT;
    }

    public Transform GetTransform()
    {
        return transform;
    }

    public Transform GetInteractPoint()
    {
        return _interactPoint;
    }

    public List<Renderer> GetRenderer()
    {
        return _renderers;
    }

    public bool CanInteract()
    {
        return true;
    }

    public string ActionName()
    {
        return "get more Ingredients";
    }

    public string AnimationToExecute()
    {
        return "";
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

    public Transform GoesToUsablePoint()
    {
        throw new NotImplementedException();
    }
}
