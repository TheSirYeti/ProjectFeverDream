using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class SurveyManager : GenericObject
{
    public static SurveyManager instance;
    
    [SerializeField] private SurveyInteractable[] questionaire;
    private int _currentSurvey = -1;
    private Action _surveyUpdate = delegate { };
    private void Awake()
    {
        instance = this;
        
        UpdateManager._instance.AddObject(this);
        
        DoNextQuestion();
    }

    public void DoNextQuestion()
    {
        if (_currentSurvey >= 0)
        {
            questionaire[_currentSurvey].OnSurveyEnd();
            _surveyUpdate -= questionaire[_currentSurvey].OnSurveyUpdate;
        }

        _currentSurvey++;

        if (_currentSurvey >= questionaire.Length)
        {
            //algo
            return;
        }
        
        questionaire[_currentSurvey].OnSurveyStart();
        _surveyUpdate += questionaire[_currentSurvey].OnSurveyUpdate;
    }

    public override void OnUpdate()
    {
        _surveyUpdate();
    }
}
