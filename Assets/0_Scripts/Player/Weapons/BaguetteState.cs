using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaguetteState : MonoBehaviour
{
    public List<GameObject> allBaguetteStates;
    public Animator animator;
    private int lastState;

    private void Start()
    {
        lastState = allBaguetteStates.Count - 1;
        EventManager.Subscribe("OnBaguetteChangeState", SetCurrentState);
    }

    void SetCurrentState(object[] parameters)
    {
        foreach (var baguette in allBaguetteStates)
        {
            baguette.SetActive(false);
        }
        
        allBaguetteStates[(int)parameters[0]].SetActive(true);
        
        if ((int)parameters[0] == lastState)
        {
            animator.Play("BigBaguetteToDualBaguette");
        }
    }
}
