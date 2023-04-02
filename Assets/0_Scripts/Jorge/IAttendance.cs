using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IAttendance
{
    public abstract void Interact();
    public abstract Transform GetTransform();
    public abstract bool CanInteract();
}
