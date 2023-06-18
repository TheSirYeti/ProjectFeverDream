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
        _screenMAT.SetFloat("_Controlcolor", controlColor);
        _screenMAT.SetFloat("_Controlring", lockValue);
        _screenMAT.SetFloat("_NoInteractive", _interactive);
    }
}
