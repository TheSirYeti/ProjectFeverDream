using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CutsceneToggler : GenericObject
{
    public GameObject cameraGO;
    private bool isInCutscene = false;
    private GameObject player;
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    public override void OnStart()
    {
        player = GameManager.Instance.Player.gameObject;
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
        if (isInCutscene)
        {
            DoPlayerPos();
        }
    }

    public void StartCutscene()
    {
        EventManager.Trigger("ChangeMovementState", false);
        
        GameManager.Instance.GetCamera().gameObject.SetActive(false);

        cameraGO.gameObject.SetActive(true);

        isInCutscene = true;
    }
    
    public void StopCutscene()
    {
        EventManager.Trigger("ChangeMovementState", true);

        cameraGO.gameObject.SetActive(false);
        
        GameManager.Instance.GetCamera().gameObject.SetActive(true);

        isInCutscene = false;
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
