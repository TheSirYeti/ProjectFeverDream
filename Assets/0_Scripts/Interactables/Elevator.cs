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

    public void Interact(GameObject usableItem = null)
    {
        StartCoroutine(DoElevatorCycle());
        interactable = false;
        Debug.Log("ASCENSOR");
    }
    //TODO: Set Interfaces
    public void Interact(IAssistInteract usableItem = null)
    {
        throw new System.NotImplementedException();
    }

    public Assistant.Interactuables GetType()
    {
        return _type;
    }

    public Assistant.JorgeStates GetState()
    {
        throw new System.NotImplementedException();
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
        throw new System.NotImplementedException();
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

    public bool IsInteractable()
    {
        return interactable;
    }
}
