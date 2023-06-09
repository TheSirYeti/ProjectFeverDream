using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class PingSystem : GenericObject
{
    [SerializeField] private Image ping;
    [SerializeField] private Transform currentTarget;

    private bool isPingEnabled = false;

    public Renderer buttonRenderer;

    private float fadeInValue = 0.5f;
    
    private float yBias = 35f;
    private Camera cam;
    
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    public override void OnStart()
    {
        cam = Camera.main;
    }

    public override void OnUpdate()
    {
        if (!isPingEnabled) return;
        
        if(currentTarget != null)
            SetPingPosition();
    }

    public void SetPingPosition()
    {
        var dir = currentTarget.position - cam.transform.position;
        if (buttonRenderer.isVisible && Vector3.Angle(cam.transform.forward, dir) < 90)
        {
            ping.gameObject.SetActive(true);
            ping.transform.position = cam.WorldToScreenPoint(currentTarget.position) + new Vector3(0f, yBias, 0f);
        }
        else ping.gameObject.SetActive(false);
    }

    void DoPingStart(object[] parameters)
    {
        isPingEnabled = true;
        LeanTween.value(0, 1, fadeInValue).setOnUpdate((float value) =>
        {
            ping.color = new Color(ping.color.r, ping.color.g, ping.color.b, value);
        });
    }
    
    void DoPingEnd()
    {
        LeanTween.value(1, 0, fadeInValue).setOnUpdate((float value) =>
        {
            ping.color = new Color(ping.color.r, ping.color.g, ping.color.b, value);
        });
        isPingEnabled = false;
    }
    
    
}
