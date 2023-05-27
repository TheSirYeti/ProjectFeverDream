using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class DoorPanel : GenericObject, IAssistInteract, IInteractUI
{
    [SerializeField] Assistant.Interactuables _type;

    bool _isClose = true;
    [SerializeField] Animator _door;
    [SerializeField] Transform _interactPoint;

    [Header("TEMP")] [SerializeField] 
    private Material activatedMat;
    [SerializeField] private List<Renderer> renderers;

    public override void OnStart()
    {
        if(renderers == null)
            renderers = GetComponentsInChildren<Renderer>().ToList();
    }

    public Transform GetTransform()
    {
        return transform;
    }

    public void Interact(GameObject usableItem = null)
    {
        foreach (var rend in renderers)
        {
            rend.material = activatedMat;
        }
        
        _door.SetBool("open", true);
        _isClose = false;
    }

    public bool CanInteract()
    {
        return _isClose;
    }

    public string AnimationToExecute()
    {
        return "door";
    }

    public Transform GetInteractPoint()
    {
        return _interactPoint;
    }

    public List<Renderer> GetRenderer()
    {
        return null;
    }

    Assistant.Interactuables IAssistInteract.GetType()
    {
        return _type;
    }

    public string ActionName()
    {
        return "Open the door";
    }

    public bool IsInteractable()
    {
        return _isClose;
    }
}
