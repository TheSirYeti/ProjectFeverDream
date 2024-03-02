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

    protected override void GeneralSettings()
    {
        if (_enabled)
            _speedEffect._Alpha.value = _effectAlpha;
    }

    public override void EffectEnabled(bool on)
    {
        LeanTween.cancel(gameObject);
        if (on)
        {
            _speedEffect.active = true;
            LeanTween.value(_speedEffect._Alpha.value, 1, .3f)
                .setOnUpdate(value =>
                {
                    _speedEffect._Alpha.value = value;
                });
        }
        else
        {
            LeanTween.value(_speedEffect._Alpha.value, 0, .3f)
                .setOnUpdate(value =>
                {
                    _speedEffect._Alpha.value = value;
                })
                .setOnComplete(o => _speedEffect.active = false);
        }
    }
}
