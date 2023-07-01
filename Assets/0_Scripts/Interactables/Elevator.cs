using System.Collections;
using System.Collections.Generic;
using UnityEngine;
//using UnityFx.Outline;

public class Elevator : GenericObject, IAssistInteract
{
    //[SerializeField] private OutlineBehaviour _outline;
    [SerializeField] Assistant.Interactuables _type;

    [SerializeField] private Transform interactPoint;
    [SerializeField] private GameObject elevator;
    [SerializeField] private Transform startPoint, endPoint;
    [SerializeField] private float elevationTime, holdTime;
    private bool interactable = true;
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    public override void OnStart()
    {
        
    }
    
    //TODO: Set Interfaces
    public void Interact(IAssistInteract usableItem = null)
    {
        StartCoroutine(DoElevatorCycle());
        interactable = false;
        Debug.Log("ASCENSOR");
    }

    public Assistant.Interactuables GetType()
    {
        return _type;
    }

    public Assistant.JorgeStates GetState()
    {
        return Assistant.JorgeStates.INTERACT;
    }

    public Transform GetTransform()
    {
        return transform;
    }

    public Transform GetInteractPoint()
    {
        return interactPoint;
    }

    public List<Renderer> GetRenderer()
    {
        throw new System.NotImplementedException();
    }

    public bool CanInteract()
    {
        return interactable;
    }

    public string AnimationToExecute()
    {
        return "pluggingWire";
    }

    public void ChangeOutlineState(bool state)
    {
        //_outline.OutlineWidth = state ? 4 : 0;;
    }

    public int InteractID()
    {
        throw new System.NotImplementedException();
    }

    public bool isAutoUsable()
    {
        return false;
    }

    public Transform UsablePoint()
    {
        throw new System.NotImplementedException();
    }

    IEnumerator DoElevatorCycle()
    {
        while (true)
        {
            LeanTween.moveY(elevator, endPoint.position.y, elevationTime);

            yield return new WaitForSeconds(elevationTime + holdTime);
            
            LeanTween.moveY(elevator, startPoint.position.y, elevationTime);

            yield return new WaitForSeconds(elevationTime + holdTime);
        }
    }

    public string ActionName()
    {
        return "enable the Elevator";
    }
}
