using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectiveData : GenericObject
{
    [SerializeField] private string newObjectiveTitle, newObjectiveDescription;
    [SerializeField] private bool needsEvent;
    [SerializeField] private string eventName;
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnStart()
    {
        EventManager.Subscribe(eventName, ChangeObjective);
    }

    public void ChangeObjective(object[] parameters)
    {
        EventManager.Trigger("ChangeObjective", newObjectiveTitle, newObjectiveDescription);
    }

    private void OnEnable()
    {
        ChangeObjective(null);
    }
}
