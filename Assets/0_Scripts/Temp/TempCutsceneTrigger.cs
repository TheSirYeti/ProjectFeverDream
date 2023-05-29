using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TempCutsceneTrigger : GenericObject
{
    public float timeToWait;
    public int sceneToLoad;
    private bool hasTriggered = false;

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player" && !hasTriggered)
        {
            hasTriggered = true;
            GameManager.Instance.FadeIn();
            GameManager.Instance.PauseGame();
            StartCoroutine(DoWaiting());
        }
    }

    IEnumerator DoWaiting()
    {
        yield return new WaitForSeconds(timeToWait);
        GameManager.Instance.ChangeScene(sceneToLoad, false);
        yield return null;
    }
}