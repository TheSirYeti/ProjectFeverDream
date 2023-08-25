using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public class BorderCinematicEffectManager : PostProccesingAbstract
{
    private BorderCinematic_EffectPPSSettings _borderCinematicEffect;

    [Header("Variables")]
    [Range(0f, 1.0f)]
    [SerializeField] private float _slider;

    private void Start()
    {
        _postProcessVolume = GetComponent<PostProcessVolume>();
        _postProcessVolume.profile.TryGetSettings(out _borderCinematicEffect);
    }

    public void Update()
    {
        EffectEnabled(_enabled);
        GeneralSettings();
    }
    protected override void GeneralSettings()
    {
        if (_enabled)
        {
            _borderCinematicEffect._SliderBorder.value = _slider;
        }
    }
    protected override void EffectEnabled(bool on)
    {
        if (on)
            _borderCinematicEffect.active = true;
        else
            _borderCinematicEffect.active = false;
    }
}
