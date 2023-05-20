using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IAssistUsable
{
    public abstract void UseItem(IAssistPickUp usable);
    public abstract GameObject GetGameObject();
    public abstract int InteractID();
}
