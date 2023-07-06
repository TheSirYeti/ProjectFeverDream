using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

public class View : GenericObject
{
    private Model _model;
    public Animator _animator;
    private WeaponManager _weaponManager;

    [SerializeField] private Transform _hitParticlesPoint;

    [SerializeField] private List<ParticleSystem> _fullBaggeteSlice;
    [SerializeField] private List<ParticleSystem> _brokenBaggeteSlice;

    [SerializeField] private List<ParticleSystem> _toasterParticles;

    [SerializeField] private ParticleSystem _bagguetHit;
    
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    public override void OnAwake()
    {
        EventManager.Subscribe("OnViewStart", OnViewStart);
        EventManager.Subscribe("PlayAnimation", PlayAnimation);
        EventManager.Subscribe("VFX_FullSlice", FullSlice);
        EventManager.Subscribe("VFX_BrokenSlice", BrokenSlice);
        EventManager.Subscribe("VFX_BaggueteHit", BagguetsHitEffect);
        EventManager.Subscribe("VFX_ToasterON", ToasterVFX_ON);
        EventManager.Subscribe("VFX_ToasterOFF", ToasterVFX_OFF);

        _bagguetHit.transform.parent = null;
        _animator = GetComponent<Animator>();
    }
    
    private void OnViewStart(params object[] parameters)
    {
        _model = (Model)parameters[0];
        _weaponManager = (WeaponManager)parameters[1];
    }

    #region Animator
    
    public void SetAnimatorController(RuntimeAnimatorController animCont)
    {
        var parameters = _animator.parameters;

        foreach (var parameter in parameters)
        {
            if (parameter.type == AnimatorControllerParameterType.Bool)
            {
                _animator.SetBool(parameter.name, false);
            }
            else if (parameter.type == AnimatorControllerParameterType.Trigger)
            {
                _animator.ResetTrigger(parameter.name);
            }
            else if (parameter.type == AnimatorControllerParameterType.Int)
            {
                _animator.SetInteger(parameter.name, 0);
            }
        }
        
        _animator.runtimeAnimatorController = animCont;
    }
    
    public void PlayAnimation(params object[] parameters)
    {
        _animator.Play((string)parameters[0]);
    }

    public void SetTrigger(string triggerName)
    {
        _animator.SetTrigger(triggerName);
    }

    public void ResetTrigger(string triggerName)
    {
        _animator.ResetTrigger(triggerName);
    }

    public void SetBool(string boolName, bool state)
    {
        _animator.SetBool(boolName, state);
    }

    public void SetInt(string intName, int value)
    {
        _animator.SetInteger(intName, value);
    }
    
    #endregion


    #region Weapons VFX

    void FullSlice(params object[] parameters)
    {
        _fullBaggeteSlice[(int)parameters[0]].Play();
    }

    void BrokenSlice(params object[] parameters)
    {
        _brokenBaggeteSlice[(int)parameters[0]].Play();
    }

    void BagguetsHitEffect(params object[] parameters)
    {
        Debug.Log("a");
        _bagguetHit.transform.position = _hitParticlesPoint.position;
        _bagguetHit.transform.rotation = _hitParticlesPoint.rotation;

        _bagguetHit.Play();
    }

    void ToasterVFX_ON(params object[] parameters)
    {
        if ((int)parameters[0] == 0)
        {
            _toasterParticles[(int)parameters[1]].gameObject.SetActive(true);
            _toasterParticles[(int)parameters[2]].gameObject.SetActive(true);
            _toasterParticles[(int)parameters[3]].gameObject.SetActive(true);
        }
        _toasterParticles[(int)parameters[0]].Play();
    }

    void ToasterVFX_OFF(params object[] parameters)
    {
        _toasterParticles[(int)parameters[0]].Stop();
        
        if ((int)parameters[0] == 0)
        {
            _toasterParticles[(int)parameters[1]].gameObject.SetActive(false);
            _toasterParticles[(int)parameters[2]].gameObject.SetActive(false);
            _toasterParticles[(int)parameters[3]].gameObject.SetActive(false);
        }
    }

    #endregion


    #region Events

    public void ShootEvent()
    {
        _weaponManager.ExecuteShoot();
    }

    public void ReloadEvent()
    {
        _weaponManager.ExecuteReload();
    }
    
    public void AEvent_FullBaggueteVFX(int attack)
    {
        FullSlice(attack);
    }
    
    public void AEvent_BrokenBaggueteVFX(int attack)
    {
        BrokenSlice(attack);
    }

    public void PlayLoopingSound(SoundID soundID)
    {
        if (SoundManager.instance == null) return;

        if (!SoundManager.instance.isSoundPlaying(soundID))
        {
            SoundManager.instance.PlaySound(soundID, true);
        }
    }

    public void AEvent_ChangeRenderer()
    {
        _weaponManager.ChangeRenderer();
    }

    #endregion
}
