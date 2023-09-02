using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class DisplayHitmarkers : GenericObject
{
    [SerializeField] private Image normalHitmarker, headshotHitmarker, weakHitmarker, deadHitmarker;
    [SerializeField] private float hitmarkerDuration;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }
    
    public override void OnStart()
    {
        EventManager.Subscribe("OnDamageableHit", TriggerHitmarker);
    }

    void TriggerHitmarker(object[] parameters)
    {
        int hitType = (int)parameters[0];

        switch (hitType)
        {
            case 0:
                StopCoroutine(DoHitmarkerDisplay(normalHitmarker));
                StartCoroutine(DoHitmarkerDisplay(normalHitmarker));
                break;
            case 1:
                StopCoroutine(DoHitmarkerDisplay(headshotHitmarker));
                StartCoroutine(DoHitmarkerDisplay(headshotHitmarker));
                break;
            case 2:
                StopCoroutine(DoHitmarkerDisplay(weakHitmarker));
                StartCoroutine(DoHitmarkerDisplay(weakHitmarker));
                break;
            case 3:
                StopCoroutine(DoHitmarkerDisplay(deadHitmarker));
                StartCoroutine(DoHitmarkerDisplay(deadHitmarker));
                break;
            default:
                StopCoroutine(DoHitmarkerDisplay(normalHitmarker));
                StartCoroutine(DoHitmarkerDisplay(normalHitmarker));
                break;
        }
    }

    IEnumerator DoHitmarkerDisplay(Image hitmarker)
    {
        hitmarker.enabled = true;
        yield return new WaitForSeconds(hitmarkerDuration);
        hitmarker.enabled = false;
        yield return null;
    }
}
