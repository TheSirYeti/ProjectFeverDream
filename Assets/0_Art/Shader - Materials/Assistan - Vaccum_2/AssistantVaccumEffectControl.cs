using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class AssistantVaccumEffectControl : MonoBehaviour
{
    [Header("Material & PS")]
    [SerializeField] private List<Material> _vacMaterial = new List<Material>();
    [SerializeField] private ParticleSystem _PS_AbsorbedParticles;

    [Header("Variables")]
    [Range(0.0f, 1.0f)]
    public float _fade;
    private bool fix;

    void Start()
    {
        VariableInitiation();
        _fade = 0;
    }

    void Update()
    {
        VariableInitiation();

        if (_fade >= 0.45f && fix == true)
        {
            _PS_AbsorbedParticles.Play();
            fix = false;
        }
        else if (_fade < 0.5f && fix == false)
        {
            _PS_AbsorbedParticles.Stop();
            _PS_AbsorbedParticles.Clear();
            fix = true;
        }
    }

    void VariableInitiation()
    {
        _vacMaterial[0].SetFloat("_FadeEffect", _fade);
        if (_fade < 0.41f)
            _vacMaterial[1].SetFloat("_FadeEffect", _fade);

        if (_fade < 0.41f)
            _vacMaterial[2].SetFloat("_FadeEffect", _fade);
    }
}
