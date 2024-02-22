using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class IKManager : GenericObject
{
    [SerializeField] private Animator _animator;
    [SerializeField] private bool _isActive;
    [SerializeField] private Transform _lookAtTarget;

    public override void OnStart()
    {
        if (_lookAtTarget == null)
        {
            _lookAtTarget = GameManager.Instance.Player.transform;
        }
    }

    private void OnEnable()
    {
        if (_lookAtTarget == null)
        {
            _lookAtTarget = GameManager.Instance.Player.transform;
        }
    }

    public void OnAnimatorIK(int layerIndex)
    {
        if (_animator)
        {
            if (_isActive)
            {
                _animator.SetLookAtWeight(1);
                _animator.SetLookAtPosition(_lookAtTarget.position);
            }
            else
            {
                _animator.SetLookAtWeight(0);
            }
        }
    }
}
