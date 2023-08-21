using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.UIElements;

public class RecommendSurvey : SurveyInteractable
{
    public override void OnSurveyStart()
    {
        foreach (var obj in surveyObjects)
        {
            obj.SetActive(true);
        }
    }

    public override void OnSurveyUpdate()
    {
        //nada por ahora
    }

    public override void OnSurveyEnd()
    {
        foreach (var obj in surveyObjects)
        {
            obj.SetActive(false);
        }
    }
}
