using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class EnjoyableSurvey : SurveyInteractable
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
        //throw new System.NotImplementedException();
    }

    public override void OnSurveyEnd()
    {
        foreach (var obj in surveyObjects)
        {
            obj.SetActive(false);
        }
    }
}
