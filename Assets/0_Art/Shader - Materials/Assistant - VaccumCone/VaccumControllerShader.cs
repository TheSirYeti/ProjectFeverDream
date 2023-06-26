using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VaccumControllerShader : MonoBehaviour
{
    [Header("Material")]
    [SerializeField] private Material _vaccumExternal;
    [SerializeField] private Material _vaccumInternal;

    [Header("Variables")]
    [Range(0.0f, 0.81f)]
    public float _opacity;
    [SerializeField] private ParticleSystem _PS_WindInternal;

    [Header("Color")]
    [SerializeField] private Color _wind;
    void Start()
    {
        VariableInitiation();
    }

    void Update()
    {
        VariableInitiation();

        if(_opacity >= 0.81f)
            _PS_WindInternal.Play();
        else if (_opacity < 0.81f)
            _PS_WindInternal.Stop();
    }

    void VariableInitiation()
    {
        _vaccumExternal.SetFloat("_OpacityExternal",_opacity);
        _vaccumInternal.SetFloat("_OpacityInternal",_opacity);

        _vaccumExternal.SetColor("_Base",_wind);
        _vaccumInternal.SetColor("_Base",_wind);
    }
}
