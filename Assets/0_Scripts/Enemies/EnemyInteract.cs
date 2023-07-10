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
    [SerializeField] private Assistant.Interactuables _type;

    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
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
        return _interactPoint;
    }

    public List<Renderer> GetRenderer()
    {
        return _renderers;
    }

    public void Interact(IAssistInteract usableItem = null)
    {
        UpdateManager._instance.RemoveObject(this);
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