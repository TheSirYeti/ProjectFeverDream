using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class View : GenericObject
{
    Model _model;
    Animator _animator;
    WeaponManager _weaponManager;

    [SerializeField] private Transform[] _hands;
    
    [SerializeField] List<ParticleSystem> _fullBaggeteSlice;
    [SerializeField] List<ParticleSystem> _brokenBaggeteSlice;

    [SerializeField] List<ParticleSystem> _toasterParticles;

    [SerializeField] ParticleSystem _bagguetHit;
    
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
        
        Transform newParticlePos = _hands[(int)parameters[0]];
        _bagguetHit.transform.position = newParticlePos.position;
        _bagguetHit.transform.rotation = newParticlePos.rotation;

        _bagguetHit.Play();
    }

    void ToasterVFX_ON(params object[] parameters)
    {
        _toasterParticles[(int)parameters[0]].Play();
    }

    void ToasterVFX_OFF(params object[] parameters)
    {
        _toasterParticles[(int)parameters[0]].Stop();
    }

    #endregion


    #region Events

    public void ShootEvent()
    {
        _weaponManager.ExecuteShoot();
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

    #endregion
}
