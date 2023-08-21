using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class SurveyInteractable : GenericObject
{
    [SerializeField] protected List<GameObject> surveyObjects;
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    public abstract void OnSurveyStart();
    public abstract void OnSurveyUpdate();
    public abstract void OnSurveyEnd(); 
}
