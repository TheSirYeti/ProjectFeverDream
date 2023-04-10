using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class View : MonoBehaviour
{
    Model _model;
    Animator _animator;
    WeaponManager _weaponManager;

    private void Awake()
    {
        EventManager.Subscribe("OnViewStart", OnViewStart);
        EventManager.Subscribe("PlayAnimation", PlayAnimation);
        _animator = GetComponent<Animator>();
    }

    public void OnViewStart(params object[] parameters)
    {
        _model = (Model)parameters[0];
        _weaponManager = (WeaponManager)parameters[1];
    }

    void PlayAnimation(params object[] parameters)
    {
        _animator.Play((string)parameters[0]);
    }

    void ChangeAnimationSpeed(params object[] parameters)
    {
        //_animator.GetCurrentAnimatorClipInfo(0).
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

    //Seccion de Eventos
    public void ShootEvent()
    {
        _weaponManager.ExecuteShoot();
    }

    public void ReloadEvent()
    {

    }
}
