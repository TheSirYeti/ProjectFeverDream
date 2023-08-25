using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public class LowHPEffectManager : PostProccesingAbstract
{
    private LowHP_EffectPPSSettings _lowHPEffect;

    [Header("Variables")]
    [Range(0f, 1.57f)]
    [SerializeField] private float _amountCorners;
    [Range(0f, 0.4f)]
    [SerializeField] private float _grayScale;

    private void Start()
    {
        _postProcessVolume = GetComponent<PostProcessVolume>();
        _postProcessVolume.profile.TryGetSettings(out _lowHPEffect);
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
            _lowHPEffect._AmountCorners.value = _amountCorners;
            _lowHPEffect._Grayscale.value = _grayScale;
        }
    }
    protected override void EffectEnabled(bool on)
    {
        if (on)
            _lowHPEffect.active = true;
        else
            _lowHPEffect.active = false;
    }
}
