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
    [SerializeField] private Renderer _outlineRenderer;
    [SerializeField] private Interactuables _type;

    private Material[] _initialMats;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
        _outline.enabled = false;
        _initialMats = _outlineRenderer.materials;
    }

    public override void OnLateUpdate()
    {
        _interactPoint.position = transform.position + Vector3.up * 1.5f;
    }

    private void OnDestroy()
    {
        _outline.enabled = false;
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

        if (state)
        {
            _outline.OutlineWidth = 10;
        }
        else
        {
            _outline.OutlineWidth = 0;

            _outlineRenderer.materials = _initialMats;
        }
        
        _outline.enabled = state;
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
        _outline.enabled = false;
        Destroy(_outline);
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