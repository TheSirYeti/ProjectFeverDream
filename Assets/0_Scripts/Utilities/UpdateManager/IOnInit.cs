using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IOnInit
{
    public abstract void OnAwake();
    public abstract void OnStart();
    public abstract void OnLateStart();
}
