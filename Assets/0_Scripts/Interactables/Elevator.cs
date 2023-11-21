using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

//using UnityFx.Outline;

public class Elevator : GenericObject, IAssistInteract
{
    [SerializeField] private Outline _outline;
    [SerializeField] private ScreenControllerShader _screenControllerShader;
    [SerializeField] Assistant.Interactuables _type;
    
    [SerializeField] private ParticleSystem vfx;
    [SerializeField] private SpatialSound sfx;

    [SerializeField] private Transform interactPoint;
    [SerializeField] private Transform _elevator;
    [SerializeField] private float elevatorSpeed;
    [SerializeField] private float holdTime;
    private bool interactable = true;

    [SerializeField] private Transform[] _wayPoints;
    [SerializeField] private bool _movesBackward = false;
    private int _waypointIndex = 1;
    private Vector3 _actualDir;
    private int _waypointDir = 1;
    private bool _isWaiting = false;
    private float _timer = 0;
    private bool _isActive = false;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnStart()
    {
    }

    public override void OnUpdate()
    {
        if (!_isActive) return;

        if (_isWaiting)
        {
            _timer += Time.deltaTime;
            if (_timer > holdTime)
            {
                _isWaiting = false;
                _timer = 0;
            }

            return;
        }

        var actualDir = _wayPoints[_waypointIndex].position - _elevator.position;
        _elevator.position += actualDir.normalized * (elevatorSpeed * Time.deltaTime);

        if (!(Vector3.Distance(_elevator.position, _wayPoints[_waypointIndex].position) < 0.05f)) return;

        vfx.Play();
        sfx.PlaySound();
        
        _isWaiting = true;
        _waypointIndex += _waypointDir;

        if (_waypointIndex <= _wayPoints.Length - 1) return;

        if (_movesBackward)
            _waypointDir *= -1;
        else
            _waypointIndex = 0;
    }

    //TODO: Set Interfaces
    public void Interact(IAssistInteract usableItem = null)
    {
        _screenControllerShader.ChangeSettings(0, 1, 1);
        interactable = false;
        _isActive = true;
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
        if (_outline != null)
        {
            _outline.enabled = state;
            _outline.OutlineWidth = 10;
        }
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

    public string ActionName()
    {
        return "enable the Elevator";
    }
}