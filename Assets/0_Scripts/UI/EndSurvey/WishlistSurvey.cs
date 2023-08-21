using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class WishlistSurvey : SurveyInteractable
{
    [SerializeField] private Slider _slider;
    [SerializeField] private Button _submitButton;
    [SerializeField] private float _sliderAdditive;
    
    public override void OnSurveyStart()
    {
        foreach (var obj in surveyObjects)
        {
            obj.SetActive(true);
        }
    }

    public override void OnSurveyUpdate()
    {
        _slider.value += _sliderAdditive;

        if (_slider.value >= 1)
        {
            _submitButton.interactable = true;
        }
        else _submitButton.interactable = false;
    }

    public override void OnSurveyEnd()
    {
        foreach (var obj in surveyObjects)
        {
            obj.SetActive(false);
        }
    }
}
