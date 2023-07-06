using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class DoorPanel : GenericObject, IAssistInteract
{
    [SerializeField] private Outline _outline;
    [SerializeField] Assistant.Interactuables _type;

    bool _isClose = true;
    [SerializeField] Animator _door;
    [SerializeField] Transform _interactPoint;
    [Space(20)] 
    [SerializeField] private List<AudioSource> audioSources;
    private List<int> audioIDs = new List<int>();

    [Header("TEMP")] 
    [SerializeField] private ScreenControllerShader _screenControllerShader;
    [SerializeField] private List<Renderer> renderers;

    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }
    
    public override void OnStart()
    {
        if(renderers == null)
            renderers = GetComponentsInChildren<Renderer>().ToList();
        
        foreach (var sfx in audioSources)
        {
            audioIDs.Add(SoundManager.instance.AddSFXSource(sfx));
        }
    }

    public Assistant.JorgeStates GetState()
    {
        return Assistant.JorgeStates.INTERACT;
    }

    public Transform GetTransform()
    {
        return transform;
    }

    public void Interact(IAssistInteract usableItem = null)
    {
        _door.SetBool("open", true);
        SoundManager.instance.PlaySoundByInt(audioIDs[0]);
        _screenControllerShader.ChangeSettings(0, 1, 1);
        _isClose = false;
    }

    public bool CanInteract()
    {
        return _isClose;
    }

    public string AnimationToExecute()
    {
        return "pluggingWire";
    }

    //TODO: Set Interfaces
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

    public Transform GetInteractPoint()
    {
        return _interactPoint;
    }

    public List<Renderer> GetRenderer()
    {
        return null;
    }

    Assistant.Interactuables IAssistInteract.GetType()
    {
        return _type;
    }

    public string ActionName()
    {
        return "Open the door";
    }
}
