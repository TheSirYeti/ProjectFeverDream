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

    protected override void GeneralSettings()
    {
        if (_enabled)
        {
            _borderCinematicEffect._SliderBorder.value = _slider;
        }
    }
    public override void EffectEnabled(bool on)
    {
        if (on)
        {
            _borderCinematicEffect.active = true;
            _borderCinematicEffect._SliderBorder.value = 1;
        }
        else
            _borderCinematicEffect.active = false;
    }
}
