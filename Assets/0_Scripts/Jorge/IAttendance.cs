using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IAttendance
{
    public abstract void Interact();
    public abstract Assistant.Interactuables GetType();
    public abstract Transform GetTransform();
    public abstract Transform GetInteractPoint();
    public abstract List<Renderer> GetRenderer();
    public abstract bool CanInteract();
    public abstract string AnimationToExecute();
}
