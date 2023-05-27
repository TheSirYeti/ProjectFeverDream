using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public abstract class GenericObject : MonoBehaviour, IOnInit, IOnUpdate
{
    //Priority for update
    public int priority = 0;
    //The object is pausable
    public bool isPausable = true;

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