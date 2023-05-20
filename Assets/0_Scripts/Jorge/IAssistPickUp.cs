using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IAssistPickUp
{
    public abstract void Use(IAssistUsable actionable);
    public abstract GameObject GetGameObject();
    public abstract bool IsAutoUsable();
    public abstract Transform GetTarget();
    public abstract int InteractID();
}
