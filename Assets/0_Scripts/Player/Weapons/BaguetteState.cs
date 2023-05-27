using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaguetteState : GenericObject
{
    public List<GameObject> allBaguetteStates;
    private int endState;

    private int lastState = 0;

    public override void OnStart()
    {
        endState = allBaguetteStates.Count - 1;
        EventManager.Subscribe("OnBaguetteChangeState", SetCurrentState);
    }

    void SetCurrentState(object[] parameters)
    {
        if (lastState == (int)parameters[0]) return;

        foreach (var baguette in allBaguetteStates)
        {
            baguette.SetActive(false);
        }
        
        allBaguetteStates[(int)parameters[0]].SetActive(true);
        
        if ((int)parameters[0] == endState)
        {
            EventManager.Trigger("PlayAnimation", "BigBaguetteToDualBaguette");
        }
    }
}
