using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IAssistInteract
{
    public void Interact(IAssistInteract usableItem = null);
    public Interactuables GetInteractType();
    public Assistant.JorgeStates GetState();
    public Transform GetTransform();
    public Transform GetInteractPoint();
    public List<Renderer> GetRenderer();
    public bool CanInteract();
    public string ActionName();
    public string AnimationToExecute();
    public void ChangeOutlineState(bool state);
    public bool CanInteractWith(IAssistInteract assistInteract);
    public bool IsAutoUsable();
    public Transform GoesToUsablePoint();
}
