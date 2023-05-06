using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TutorialScreens : MonoBehaviour
{
    [SerializeField] private List<GameObject> tutorialSigns;
    [SerializeField] private float timeSignActive;

    private void Start()
    {
        EventManager.Subscribe("OnTutorialTriggered", TriggerTutorial);
    }

    public void TriggerTutorial(object[] parameters)
    {
        foreach (var sign in tutorialSigns)
        {
            sign.SetActive(false);
        }
        StartCoroutine(DoTutorialSign((int)parameters[0]));
    }

    IEnumerator DoTutorialSign(int sign)
    {
        tutorialSigns[sign].SetActive(true);
        yield return new WaitForSeconds(timeSignActive);
        tutorialSigns[sign].SetActive(false);
        yield return null;
    }
}
