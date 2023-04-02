using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DoorPanel : MonoBehaviour, IAttendance
{
    bool _isClose = true;
    [SerializeField] Animator _door;

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
