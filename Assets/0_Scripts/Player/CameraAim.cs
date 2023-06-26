using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
//using UnityFx.Outline;

public class CameraAim
{
    private Camera _camera;
    private Assistant _assistant;
    private float _interactDistance;

    private IAssistInteract _actualInteract;

    private bool _isActive = true;

    public CameraAim(Camera camera, Assistant assistant, float interactDistance)
    {
        _camera = camera;
        _assistant = assistant;

        _interactDistance = interactDistance;
        
        EventManager.Subscribe("ChangeMovementState", ChangeCinematicState);
    }

    void ChangeCinematicState(params object[] parameters)
    {
        _isActive = (bool)parameters[0];

        if (_actualInteract != null)
        {
            _actualInteract.ChangeOutlineState(false);
        }
    }

    public void CheckActualAim()
    {
        if (!_isActive)
        {
            return;
        }
        
        var colliders =
            Physics.OverlapSphere(_camera.transform.position, _interactDistance, LayerManager.LM_ALLINTERACTS);
        //Debug.Log(1);
        if (!colliders.Any())
        {
            if (_actualInteract == null) return;

            _actualInteract.ChangeOutlineState(false);
            _actualInteract = null;
            EventManager.Trigger("InteractUI", false);

            return;
        }

        //Debug.Log(2);
        var objectInView = colliders.Where(x =>
        {
            var maxDistance = new Vector3(0.5f, 0.5f, 0);
            var dir = x.transform.position - _camera.transform.position;
            Vector3 position;
            return !Physics.Raycast(_camera.transform.position, dir, dir.magnitude * 0.95f, LayerManager.LM_OBSTACLE)
                   && Mathf.Abs((_camera.WorldToViewportPoint((position = x.transform.position)) - maxDistance).x) <
                   0.2f
                   && Mathf.Abs((_camera.WorldToViewportPoint(position) - maxDistance).y) < 0.2f
                   && Vector3.Angle(_camera.transform.forward, dir) < 90;
        });

        if (!objectInView.Any())
        {
            if (_actualInteract == null) return;

            _actualInteract.ChangeOutlineState(false);
            _actualInteract = null;
            EventManager.Trigger("InteractUI", false);

            return;
        }

        //Debug.Log(3);

        var closeObj = objectInView.OrderBy(x =>
            {
                var maxDistance = new Vector2(0.5f, 0.5f);
                var vector2 = new Vector2(_camera.WorldToViewportPoint(x.transform.position).x,
                    _camera.WorldToViewportPoint(x.transform.position).y) - maxDistance;
                return vector2.magnitude;
            })
            .First().gameObject
            .GetComponent<IAssistInteract>();
        
        //Debug.Log(4);
        if (closeObj == null || !closeObj.CanInteract())
        {
            _actualInteract?.ChangeOutlineState(false);
            _actualInteract = null;
            EventManager.Trigger("InteractUI", false);

            return;
        }
        //Debug.Log(5);
        if (closeObj == _actualInteract) return;

        _actualInteract?.ChangeOutlineState(false);
        _actualInteract = closeObj;
        _actualInteract.ChangeOutlineState(true);
        EventManager.Trigger("InteractUI", true, _actualInteract.ActionName());
    }

    public void Interact()
    {
        if (_actualInteract == null) return;


        if (_actualInteract.GetState() == Assistant.JorgeStates.USEIT &&
            _actualInteract.InteractID() == _assistant._holdingItem.InteractID())
        {
            _assistant.SetObjective(_actualInteract.GetInteractPoint(), _actualInteract.GetState());
        }
        else if (_actualInteract.GetState() != Assistant.JorgeStates.USEIT)
        {
            _assistant.SetObjective(_actualInteract.GetInteractPoint(), _actualInteract.GetState());
        }
    }
}