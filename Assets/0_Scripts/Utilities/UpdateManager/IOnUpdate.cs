using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IOnUpdate
{
    public abstract void OnUpdate();
    
    public abstract void OnFixedUpdate();
    
    public abstract void OnLateUpdate();
}
