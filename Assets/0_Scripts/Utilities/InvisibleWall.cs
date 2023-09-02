using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InvisibleWall : GenericObject
{
    [SerializeField] private bool isInvisible = true;
    private Renderer renderer;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }
    
    public override void OnStart()
    {
        renderer = GetComponent<Renderer>();
        ToggleVisibility(null);
        
        EventManager.Subscribe("OnColliderToggled", ToggleVisibility);
    }

    public void ToggleVisibility(object[] parameters)
    {
        isInvisible = !isInvisible;
        renderer.enabled = isInvisible;
    }
}
