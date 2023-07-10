using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyInteract : GenericObject, IAssistInteract
{
    [SerializeField] private Enemy _enemy;
    private bool _isDead => _enemy.isDead;
    [SerializeField] private List<Renderer> _renderers;
    [SerializeField] private Outline _outline;
    [SerializeField] private Assistant.Interactuables _type;


    #region INTERACTIONS

    public Assistant.JorgeStates GetState()
    {
        return Assistant.JorgeStates.INTERACT;
    }

    public Transform GetTransform()
    {
        return transform;
    }

    public bool CanInteract()
    {
        return _isDead;
    }

    public string AnimationToExecute()
    {
        return "absorbing";
    }

    public void ChangeOutlineState(bool state)
    {
        if (_outline == null) return;

        _outline.enabled = state;
        _outline.OutlineWidth = 10;
    }

    public int InteractID()
    {
        return 1;
    }

    public bool isAutoUsable()
    {
        return false;
    }

    public Transform UsablePoint()
    {
        throw new NotImplementedException();
    }

    public Transform GetInteractPoint()
    {
        return transform;
    }

    public List<Renderer> GetRenderer()
    {
        return _renderers;
    }

    public void Interact(IAssistInteract usableItem = null)
    {
        Destroy(_enemy.gameObject);
    }

    Assistant.Interactuables IAssistInteract.GetType()
    {
        return _type;
    }

    public string ActionName()
    {
        return "Eat the Robot";
    }

    #endregion
}