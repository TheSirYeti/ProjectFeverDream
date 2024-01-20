using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnemyInteract : GenericObject, IAssistInteract
{
    [SerializeField] private Transform _interactPoint;
    [SerializeField] private Enemy _enemy;
    private bool _isDead => _enemy.isDead;
    [SerializeField] private List<Renderer> _renderers;
    [SerializeField] private Outline _outline;
    [SerializeField] private Interactuables _type;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnLateUpdate()
    {
        _interactPoint.position = transform.position + Vector3.up * 1.5f;
    }


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

    public Transform GetInteractPoint()
    {
        return _interactPoint;
    }

    public List<Renderer> GetRenderer()
    {
        return _renderers;
    }

    public void Interact(IAssistInteract usableItem = null)
    {
        UpdateManager.instance.RemoveObject(this);
        Destroy(_enemy.gameObject);
    }

    Interactuables IAssistInteract.GetInteractType()
    {
        return _type;
    }

    public string ActionName()
    {
        return "Eat the Robot";
    }

    #endregion
}