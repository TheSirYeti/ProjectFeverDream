using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class InvisibleWall : MonoBehaviour
{
    [SerializeField] private bool isInvisible = true;
    private Renderer renderer;
    
    void Start()
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
