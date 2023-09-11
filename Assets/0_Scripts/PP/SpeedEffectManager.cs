using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public class SpeedEffectManager : PostProccesingAbstract
{
    private SpeedEffect_ShaderPPSSettings _speedEffect;

    [Header("Variables")]
    [Range(0f, 1f)]
    [SerializeField] private float _effectAlpha;

    private void Start()
    {
        _postProcessVolume = GetComponent<PostProcessVolume>();
        _postProcessVolume.profile.TryGetSettings(out _speedEffect);
    }

    public void Update()
    {
        EffectEnabled(_enabled);
        GeneralSettings();
    }

    protected override void GeneralSettings()
    {
        if (_enabled)
            _speedEffect._Alpha.value = _effectAlpha;
    }

    protected override void EffectEnabled(bool on)
    {
        if (on)
            _speedEffect.active = true;
        else
            _speedEffect.active = false;
    }
}