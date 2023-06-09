using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TutorialScreens : GenericObject
{
    [SerializeField] private List<GameObject> tutorialSigns;
    [SerializeField] private float timeSignActive;

    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }
    
    public override void OnStart()
    {
        StartCoroutine(DoTutorialSign(0));
        EventManager.Subscribe("OnTutorialTriggered", TriggerTutorial);
        EventManager.Subscribe("OnTutorialExit", DisableTutorials);
    }

    public void TriggerTutorial(object[] parameters)
    {
        DisableTutorials(null);
        StartCoroutine(DoTutorialSign((int)parameters[0]));
    }

    IEnumerator DoTutorialSign(int sign)
    {
        tutorialSigns[sign].SetActive(true);
        yield return new WaitForSeconds(timeSignActive);
        tutorialSigns[sign].SetActive(false);
        yield return null;
    }

    public void DisableTutorials(object[] parameters)
    {
        foreach (var sign in tutorialSigns)
        {
            sign.SetActive(false);
        }
    }
}
