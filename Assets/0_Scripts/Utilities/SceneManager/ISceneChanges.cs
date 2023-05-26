using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface ISceneChanges
{
    public abstract void OnSceneLoad();
    public abstract void OnSceneUnload();
}
