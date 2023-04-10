using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaguetteState : MonoBehaviour
{
    public List<GameObject> allBaguetteStates;
    private int endState;

    private int lastState = 0;

    private void Start()
    {
        endState = allBaguetteStates.Count - 1;
        EventManager.Subscribe("OnBaguetteChangeState", SetCurrentState);
    }

    void SetCurrentState(object[] parameters)
    {
        if (lastState == (int)parameters[0]) return;

        foreach (var baguette in allBaguetteStates)
        {
            Debug.Log("Apago " + baguette);
            baguette.SetActive(false);
        }
        
        allBaguetteStates[(int)parameters[0]].SetActive(true);
        Debug.Log("ACTIVATED " + allBaguetteStates[(int)parameters[0]].name);
        
        if ((int)parameters[0] == endState)
        {
            Debug.Log("SEXO");
            EventManager.Trigger("PlayAnimation", "BigBaguetteToDualBaguette");
        }
    }
}
