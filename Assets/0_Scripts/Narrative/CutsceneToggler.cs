using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class CutsceneToggler : GenericObject
{
    public GameObject cameraGO;
    private bool isInCutscene = false;
    private GameObject player;
    public Transform playerCorner;
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    public override void OnStart()
    {
        player = GameManager.Instance.Player.gameObject;
        EventManager.Subscribe("OnResetTriggerLevel", StopCutsceneEvent);
    }

    /*private void OnEnable()
    {
        StartCutscene();
    }
    
    private void OnDisable()
    {
        StopCutscene();
    }*/

    public override void OnUpdate()
    {
        /*if (isInCutscene)
        {
            DoPlayerPos();
        }*/
    }

    public void StartCutscene()
    {
        player.transform.position = playerCorner.position;
        EventManager.Trigger("ChangeMovementState", false);
        
        GameManager.Instance.GetCamera().gameObject.SetActive(false);

        cameraGO.gameObject.SetActive(true);

        isInCutscene = true;
    }
    
    public void StopCutscene()
    {
        if (isInCutscene)
        {
            player.transform.position = cameraGO.transform.position;
            player.transform.rotation = cameraGO.transform.rotation;
        }
        
        EventManager.Trigger("ChangeMovementState", true);

        cameraGO.gameObject.SetActive(false);

        GameManager.Instance.GetCamera().gameObject.SetActive(true);

        isInCutscene = false;
    }
    
    public void StopCutsceneEvent(object[] parameters)
    {
        StopCutscene();
    }

    public void DoPlayerPos()
    {
        player.transform.position = cameraGO.transform.position;
        player.transform.rotation = cameraGO.transform.rotation;
    }

    public void OnLevelOver()
    {
        GameManager.Instance.NextScene();
    }
    
    public void FinalCutscene()
    {
        EventManager.Trigger("OnLevelFinished");
    }
}
