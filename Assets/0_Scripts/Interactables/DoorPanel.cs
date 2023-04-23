using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoorPanel : MonoBehaviour, IAttendance
{
    bool _isClose = true;
    [SerializeField] Animator _door;

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
}
