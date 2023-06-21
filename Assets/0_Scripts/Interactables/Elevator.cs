using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Elevator : GenericObject, IAssistInteract
{
    [SerializeField] Assistant.Interactuables _type;

    [SerializeField] private Transform interactPoint;
    [SerializeField] private GameObject elevator;
    [SerializeField] private float elevationTime, holdTime, yDiff;
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
        return transform;
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
        return "door";
    }

    public void ChangeOutlineState(bool state)
    {
        throw new System.NotImplementedException();
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
            LeanTween.moveY(elevator, elevator.transform.position.y + yDiff, elevationTime);

            yield return new WaitForSeconds(elevationTime + holdTime);
            
            LeanTween.moveY(elevator, elevator.transform.position.y - yDiff, elevationTime);

            yield return new WaitForSeconds(elevationTime + holdTime);
        }
    }

    public string ActionName()
    {
        return "enable the Elevator";
    }
}
