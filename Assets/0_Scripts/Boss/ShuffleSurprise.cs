using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ShuffleSurprise : GenericObject, IAssistInteract
{
    private bool _isGood;
    [Space(10)] [SerializeField] private Animator _animator;
    [Space(10)] [SerializeField] private Transform _interactPoint;
    [SerializeField] private GameObject _goodObjectPlate, _badObjectPlate;
    [Space(10)] [SerializeField] private string _animationOpen, _animationClose;
    [SerializeField] private GameObject _badObjectPrefab;
    [SerializeField] private Vector3 _badObjectOffset;

    private bool isShuffling = true;
    private bool chosen = false;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public void Open()
    {
        _animator.Play(_animationOpen);
    }

    public void Close()
    {
        _animator.Play(_animationClose);
    }

    void Reveal()
    {
        chosen = true;
        isShuffling = true;
        StartCoroutine(DoRevealSpawning());
    }

    public void DestroyPlate()
    {
        Destroy(gameObject);
    }

    public void SetShufflingStatus(bool status)
    {
        isShuffling = status;
    }

    public void SetGoodPlate()
    {
        _isGood = true;
        _goodObjectPlate.SetActive(true);
        _badObjectPlate.SetActive(false);
    }
    
    IEnumerator DoRevealSpawning()
    {
        Open();
        yield return new WaitForSeconds(1f);

        if (_isGood)
        {
            //Heal, sfx positivo
            yield break;
        }

        //sfx negativo
        yield return new WaitForSeconds(1f);
        GameObject trap = Instantiate(_badObjectPrefab);
        trap.transform.position = GameManager.Instance.Player.transform.position + _badObjectOffset;
    }

    #region Assistant Interact
    
    public void Interact(IAssistInteract usableItem = null)
    {
        Reveal();
    }

    public Assistant.Interactuables GetType()
    {
        return Assistant.Interactuables.DOOR;
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
        throw new NotImplementedException();
    }

    public bool CanInteract()
    {
        return !isShuffling;
    }

    public string ActionName()
    {
        return "choose this Plate";
    }

    public string AnimationToExecute()
    {
        return "pluggingWire";
    }

    public void ChangeOutlineState(bool state)
    {
        //
    }

    public int InteractID()
    {
        throw new NotImplementedException();
    }

    public bool isAutoUsable()
    {
        throw new NotImplementedException();
    }

    public Transform UsablePoint()
    {
        throw new NotImplementedException();
    }
    
    #endregion
}
