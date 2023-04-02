using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoorPanel : MonoBehaviour, IAttendance
{
    bool _isClose = true;
    Animator _door;

    void Start()
    {
        _door = GetComponentInChildren<Animator>();
    }

    public Transform GetTransform()
    {
        return transform;
    }

    public void Interact()
    {
        _door.Play("OpenDoor");
        _isClose = false;
    }

    public bool CanInteract()
    {
        return _isClose;
    }
}
