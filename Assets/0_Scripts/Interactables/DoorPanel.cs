using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoorPanel : MonoBehaviour, IAttendance
{
    [SerializeField] Assistant.Interactuables _type;

    bool _isClose = true;
    [SerializeField] Animator _door;
    [SerializeField] Transform _interactPoint;

    [Header("TEMP")] [SerializeField] 
    private Material activatedMat;
    private Renderer rend;

    private void Start()
    {
        rend = GetComponent<Renderer>();
    }

    public Transform GetTransform()
    {
        return transform;
    }

    public void Interact()
    {
        rend.material = activatedMat;
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

    Assistant.Interactuables IAttendance.GetType()
    {
        return _type;
    }
}
