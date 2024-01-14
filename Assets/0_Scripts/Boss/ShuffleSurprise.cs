using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShuffleSurprise : GenericObject
{
    [SerializeField] private bool _isGood;
    [Space(10)] [SerializeField] private Animator _animator;
    [SerializeField] private string _animationOpen, _animationClose;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public void Reveal()
    {
        _animator.Play(_animationOpen);
    }

    public void Close()
    {
        _animator.Play(_animationClose);
    }
}
