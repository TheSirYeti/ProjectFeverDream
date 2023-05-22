using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CameraAim
{
    Camera _camera;
    Assistant _assistant;
    float _interactDistance;
    LayerMask _fullLayerMask;
    LayerMask _interactMask;
    LayerMask _usableMask;
    LayerMask _pickupMask;

    IInteractUI _actualUI;

    public CameraAim(Camera camera, Assistant assistant, float interactDistance, LayerMask interactMask, LayerMask usableMask, LayerMask pickupMask)
    {
        _camera = camera;
        _assistant = assistant;

        _fullLayerMask = interactMask + usableMask + pickupMask;
        _interactDistance = interactDistance;
        _interactMask = interactMask;
        _usableMask = usableMask;
        _pickupMask = pickupMask;
    }

    public void CheckActualAim()
    {
        RaycastHit hit;
        if (Physics.Raycast(_camera.transform.position, _camera.transform.forward, out hit, _interactDistance, _fullLayerMask))
        {
            IInteractUI tempUI = hit.collider.GetComponent<IInteractUI>();

            if (tempUI == _actualUI) return;

            _actualUI = tempUI;
            EventManager.Trigger("InteractUI", true, _actualUI.ActionName());
        }
        else if(_actualUI != null)
        {
            EventManager.Trigger("InteractUI", false);
            _actualUI = null;
        }
    }

    public void Interact()
    {
        RaycastHit hit;
        if (Physics.Raycast(_camera.transform.position, _camera.transform.forward, out hit, _interactDistance, _interactMask))
        {
            Debug.Log(hit.collider.gameObject.name);
            IAssistInteract iInteract = hit.collider.gameObject.GetComponent<IAssistInteract>();

            if (iInteract == null) iInteract = hit.collider.gameObject.GetComponentInParent<IAssistInteract>();

            if (iInteract == null || !iInteract.CanInteract()) return;

            _assistant.SetObjective(iInteract.GetInteractPoint(), Assistant.JorgeStates.INTERACT);
        }
        else if (Physics.Raycast(_camera.transform.position, _camera.transform.forward, out hit, _interactDistance, _pickupMask))
        {
            IAssistPickUp iPickUp = hit.collider.gameObject.GetComponent<IAssistPickUp>();

            if (iPickUp == null) iPickUp = hit.collider.gameObject.GetComponentInParent<IAssistPickUp>();

            if (iPickUp == null) return;

            _assistant.SetObjective(iPickUp.GetGameObject().transform, Assistant.JorgeStates.PICKUP);
        }
        else if (Physics.Raycast(_camera.transform.position, _camera.transform.forward, out hit, _interactDistance, _usableMask))
        {
            IAssistUsable iPickUp = hit.collider.gameObject.GetComponent<IAssistUsable>();

            if (iPickUp == null) iPickUp = hit.collider.gameObject.GetComponentInParent<IAssistUsable>();

            if (iPickUp == null) return;

            if (iPickUp.InteractID() != _assistant._holdingItem.InteractID()) return;

            _assistant.SetObjective(iPickUp.GetGameObject().transform, Assistant.JorgeStates.USEIT);
        }
    }
}
