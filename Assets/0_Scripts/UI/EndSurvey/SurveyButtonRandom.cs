using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using Random = UnityEngine.Random;

public class SurveyButtonRandom : GenericObject, IPointerEnterHandler
{
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }


    public void OnPointerEnter(PointerEventData eventData)
    {
        DoRandomPos();
    }

    public void DoRandomPos()
    {
        transform.position = new Vector3(Random.Range(0, Screen.width), Random.Range(0, Screen.height), 0);
    }
}
