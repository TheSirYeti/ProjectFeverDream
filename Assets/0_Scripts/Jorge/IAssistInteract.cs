using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IAssistInteract
{
    public abstract void Interact(IAssistInteract usableItem = null);
    public abstract Assistant.Interactuables GetType();
    public abstract Assistant.JorgeStates GetState();
    public abstract Transform GetTransform();
    public abstract Transform GetInteractPoint();
    public abstract List<Renderer> GetRenderer();
    public abstract bool CanInteract();
    public abstract string ActionName();
    public abstract string AnimationToExecute();
    public abstract void ChangeOutlineState(bool state);
    public abstract int InteractID();
    public abstract bool isAutoUsable();
    public abstract Transform UsablePoint();
}
