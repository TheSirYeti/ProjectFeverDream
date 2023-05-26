using System.Collections;
using System.Collections.Generic;
using _0_Scripts.Utilities;
using UnityEngine;

public abstract class GenericObject : MonoBehaviour, IOnInit, IOnUpdate
{
    //Priority for update
    protected int priority = 0;
    //The object is pausable
    protected bool isPausable = true;

    #region Init Region

    public virtual void OnAwake(){}
    public virtual void OnStart(){}
    public virtual void OnLateStart(){}

    #endregion

    #region Update Region

    public virtual void OnUpdate(){}
    public virtual void OnFixedUpdate(){}
    public virtual void OnLateUpdate(){}

    #endregion
}