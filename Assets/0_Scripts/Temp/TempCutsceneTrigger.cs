using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TempCutsceneTrigger : GenericObject
{
    public List<GameObject> objectsToEnable;
    public float timeToWait;
    public int sceneToLoad;
    private bool hasTriggered = false;
    
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }
    
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player" && !hasTriggered)
        {
            hasTriggered = true;
            foreach (var obj in objectsToEnable)
            {
                obj.SetActive(true);
            }

            StartCoroutine(DoWaiting());
        }
    }

    IEnumerator DoWaiting()
    {
        yield return new WaitForSeconds(timeToWait);
        SceneLoader.instance.SetupLoadScene(sceneToLoad);
        yield return null;
    }
}
