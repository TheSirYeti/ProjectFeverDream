using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using Random = UnityEngine.Random;

public class IntroDancer : GenericObject
{
    public Animator anim;
    public int animAmount;
    
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    public override void OnStart()
    {
        int rand = Random.Range(1, animAmount + 1);
        
        Debug.Log("PLAYING " + "Dance" + rand);
        anim.Play("Dance" + rand);
    }
}
