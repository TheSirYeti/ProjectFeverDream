using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Elevator : GenericObject, IAssistInteract
{
    [SerializeField] Assistant.Interactuables _type;
    
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    public override void OnStart()
    {

    }

    public void Interact(GameObject usableItem = null)
    {
        throw new System.NotImplementedException();
    }

    public Assistant.Interactuables GetType()
    {
        return _type;
    }

    public Transform GetTransform()
    {
        return transform;
    }

    public Transform GetInteractPoint()
    {
        throw new System.NotImplementedException();
    }

    public List<Renderer> GetRenderer()
    {
        throw new System.NotImplementedException();
    }

    public bool CanInteract()
    {
        throw new System.NotImplementedException();
    }

    public string AnimationToExecute()
    {
        throw new System.NotImplementedException();
    }
}
