using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.EventSystems;
using Random = UnityEngine.Random;

public class SurveyButtonRandom : GenericObject, IPointerEnterHandler
{
    [SerializeField] private RectTransform canvas;
    
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
        transform.position = GetBottomLeftCorner(canvas) - 
                             new Vector3(Random.Range(0, canvas.rect.x), Random.Range(0, canvas.rect.y), 0);
    }
    
    Vector3 GetBottomLeftCorner(RectTransform rt)
    {
        Vector3[] v = new Vector3[4];
        rt.GetWorldCorners(v);
        return v[0];
    }
}
