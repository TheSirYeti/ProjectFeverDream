using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public class DamageScreenEffectManager : PostProccesingAbstract
{
    private DamageScreen_EffectPPSSettings _damageScreenEffect;

    [Header("Variables")]
    [Range(0f, 1.0f)]
    [SerializeField] private float _upControl;
    [Range(0f, 1.0f)]
    [SerializeField] private float _downControl;
    [Range(0f, 1.0f)]
    [SerializeField] private float _leftControl;
    [Range(0f, 1.0f)]
    [SerializeField] private float _rightControl;

    [SerializeField] private Color Emission;
    [SerializeField] private Color ShadowColor;

    private void Start()
    {
        _postProcessVolume = GetComponent<PostProcessVolume>();
        _postProcessVolume.profile.TryGetSettings(out _damageScreenEffect);
    }


    protected override void GeneralSettings()
    {
        if (_enabled)
        {
            _damageScreenEffect._ControlScreenUP.value = _upControl;
            _damageScreenEffect._ControlScreenDown.value = _downControl;
            _damageScreenEffect._ControlScreenLeft.value = _leftControl;
            _damageScreenEffect._ControlScreenRight.value = _rightControl;

            _damageScreenEffect._ColorEmission.value = Emission;
            _damageScreenEffect._ColorShadow.value = ShadowColor;
        }
    }

    private Coroutine resetCoroutine;
    public override void EffectEnabled(bool on)
    {
        if (on)
        {
            if (resetCoroutine != null)
            {
                StopCoroutine(resetCoroutine);
            }
            resetCoroutine = StartCoroutine(ResetFlash());

            _damageScreenEffect.active = true;
            _damageScreenEffect._ControlScreenUP.value = 1;
            _damageScreenEffect._ControlScreenDown.value = 1;
            _damageScreenEffect._ControlScreenLeft.value = 1;
            _damageScreenEffect._ControlScreenRight.value = 1;
            _damageScreenEffect._ColorEmission.value = Emission;
            _damageScreenEffect._ColorShadow.value = ShadowColor;
        }
        else
            _damageScreenEffect.active = false;
    }

    IEnumerator ResetFlash()
    {
        yield return new WaitForSeconds(0.2f);
        EffectEnabled(false);
    }
}
