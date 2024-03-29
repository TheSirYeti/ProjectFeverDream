using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ScreenControllerShader : MonoBehaviour
{
    [Header("Material")]
    [SerializeField] private Material _screenMAT;

    [Header("Variables")]
    [Range(0.0f, 1.0f)]
    [SerializeField] private int controlColor;
    [Range(0.0f, 1.0f)]
    [SerializeField] private float lockValue;
    [Range(0.0f, 1.0f)]
    [SerializeField] private int _interactive;

    [Header("Color")]
    [SerializeField] private Color _unlock;
    [SerializeField] private Color _lock;

    private void Awake()
    {
        if(GetComponent<Renderer>() != null)
            _screenMAT = GetComponent<Renderer>().material;
    }

    void Start()
    {
        VariableInitiation();
    }
    
    void Update()
    {
        VariableInitiation();
    }
    
    void VariableInitiation()
    {
        if (_screenMAT == null) return;
        
        _screenMAT.SetFloat("_Controlcolor", controlColor);
        _screenMAT.SetFloat("_Controlring", lockValue);
        _screenMAT.SetFloat("_NoInteractive", _interactive);
    
        _screenMAT.SetColor("_Colorunlock", _unlock);
        _screenMAT.SetColor("_Colorlock", _lock);
    }

    public void ChangeSettings(int color, float lockV, int interactive)
    {
        controlColor = color;
        lockValue= lockV;
        _interactive= interactive;
    }
}
