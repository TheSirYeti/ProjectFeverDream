using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TornadoVaccumControllerShader : MonoBehaviour
{
    [Header("Material")]
    [SerializeField] private Material _tornadoCenter;
    [SerializeField] private Material _tornadoVaccum;

    [Header("Variables")]
    [Range(0.0f, 1.0f)]
    public float _opacity;
    [SerializeField] private ParticleSystem _PS_Wind;

    [Header("Color")]
    [SerializeField] private Color _wind;

    void Start()
    {
        VariableInitiation();
        _PS_Wind.Stop();
    }

    void Update()
    {
       VariableInitiation();

        if (_opacity >= 0.6f)
        {
            if (!_PS_Wind.isPlaying) //COSAS JP
                _PS_Wind.Play();
        }
        else
            _PS_Wind.Stop();
    }

    void VariableInitiation()
    {
        _tornadoCenter.SetFloat("_Opacity", _opacity);
        _tornadoVaccum.SetFloat("_Opacity", _opacity);

        _tornadoCenter.SetColor("_ColorBase", _wind);
        _tornadoVaccum.SetColor("_ColorBase", _wind);
    }
}
