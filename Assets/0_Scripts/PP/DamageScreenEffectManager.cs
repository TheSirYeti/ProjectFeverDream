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
        LeanTween.cancel(gameObject);
        if (on)
        {
            if (resetCoroutine != null)
            {
                StopCoroutine(resetCoroutine);
            }
            resetCoroutine = StartCoroutine(ResetFlash());
            
            _damageScreenEffect.active = true;
            _damageScreenEffect._ColorEmission.value = Emission;
            _damageScreenEffect._ColorShadow.value = ShadowColor;
            
            LeanTween.value(_damageScreenEffect._ControlScreenUP.value, 1, .3f)
                .setOnUpdate(value =>
                {
                    _damageScreenEffect._ControlScreenUP.value = value;
                    _damageScreenEffect._ControlScreenDown.value = value;
                    _damageScreenEffect._ControlScreenLeft.value = value;
                    _damageScreenEffect._ControlScreenRight.value = value;
                });
        }
        else
        {
            LeanTween.value(_damageScreenEffect._ControlScreenUP.value, 0, .3f)
                .setOnUpdate(value => _damageScreenEffect._ControlScreenUP.value = value)
                .setOnComplete(o => _damageScreenEffect.active = false);
        }
    }

    IEnumerator ResetFlash()
    {
        yield return new WaitForSeconds(0.2f);
        EffectEnabled(false);
    }
}
