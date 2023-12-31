using System;
using System.Collections;
using System.Collections.Generic;
using JetBrains.Annotations;
using UnityEngine;
using UnityEngine.UI;

public class CutsceneToggler : GenericObject
{
    public GameObject cameraGO, cutscenePlayerCam, georgeDummy, cutsceneEndPos;
    private Transform originalPlayerCamTransform;
    [CanBeNull] public List<Transform> playerAnimPos;
    private bool isInCutscene = false;
    private GameObject player;
    public Transform playerCorner;
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnStart()
    {
        originalPlayerCamTransform = cutscenePlayerCam.transform;
        player = GameManager.Instance.Player.gameObject;
        EventManager.Subscribe("OnResetTriggerLevel", StopCutsceneEvent);
    }

    public void StartCutscene()
    {
        player.transform.position = playerCorner.position;
        EventManager.Trigger("ChangeMovementState", false);
        EventManager.Trigger("OnCutsceneEvent", false);
        EventManager.Trigger("OnPPCalled", PPNames.BORDERCINEMATIC, true);
        EventManager.Trigger("OnPPCalled", PPNames.LOWHP, false);
        EventManager.Trigger("OnPPCalled", PPNames.SPEEDEFFECT, false);
        EventManager.Trigger("OnPPCalled", PPNames.DAMAGESCREEN, false);
        
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
        EventManager.Trigger("OnCutsceneEvent", true);
        EventManager.Trigger("OnPPCalled", PPNames.BORDERCINEMATIC, false);

        cameraGO.gameObject.SetActive(false);

        GameManager.Instance.GetCamera().gameObject.SetActive(true);

        isInCutscene = false;
    }
    
    public void StartPlayerCutsceneWithGeorge(int posID)
    {
        player.transform.position = playerCorner.position;
        EventManager.Trigger("ChangeMovementState", false);
        EventManager.Trigger("OnCutsceneEvent", false);
        EventManager.Trigger("OnPPCalled", PPNames.BORDERCINEMATIC, true);
        EventManager.Trigger("OnPPCalled", PPNames.LOWHP, false);
        EventManager.Trigger("OnPPCalled", PPNames.SPEEDEFFECT, false);
        EventManager.Trigger("OnPPCalled", PPNames.DAMAGESCREEN, false);

        GameManager.Instance.Assistant.transform.position = playerCorner.transform.position;
        GameManager.Instance.GetCamera().gameObject.SetActive(false);

        georgeDummy.SetActive(true);
        cutscenePlayerCam.gameObject.SetActive(true);
        cutscenePlayerCam.transform.position = playerAnimPos[posID].position;
        cutscenePlayerCam.transform.rotation = playerAnimPos[posID].rotation;

        isInCutscene = true;
    }
    
    public void StopPlayerCutsceneWithGeorge()
    {
        if (isInCutscene)
        {
            GameManager.Instance.Assistant.transform.position = cutsceneEndPos.transform.position;
            player.transform.position = cutsceneEndPos.transform.position;
            player.transform.rotation = cutsceneEndPos.transform.rotation;
        }
        
        EventManager.Trigger("ChangeMovementState", true);
        EventManager.Trigger("OnCutsceneEvent", true);
        EventManager.Trigger("OnPPCalled", PPNames.BORDERCINEMATIC, false);
        

        georgeDummy.SetActive(false);
        cutscenePlayerCam.transform.rotation = originalPlayerCamTransform.rotation;
        cutscenePlayerCam.gameObject.SetActive(false);

        GameManager.Instance.GetCamera().gameObject.SetActive(true);

        isInCutscene = false;
    }
    
    public void StartPlayerCutsceneNoGeorge(int posID)
    {
        player.transform.position = playerCorner.position;
        EventManager.Trigger("ChangeMovementState", false);
        EventManager.Trigger("OnCutsceneEvent", false);
        EventManager.Trigger("OnPPCalled", PPNames.BORDERCINEMATIC, true);
        EventManager.Trigger("OnPPCalled", PPNames.LOWHP, false);
        EventManager.Trigger("OnPPCalled", PPNames.SPEEDEFFECT, false);
        EventManager.Trigger("OnPPCalled", PPNames.DAMAGESCREEN, false);
        
        //GameManager.Instance.Assistant.transform.position = playerCorner.transform.position;
        GameManager.Instance.GetCamera().gameObject.SetActive(false);

        //georgeDummy.SetActive(true);
        cutscenePlayerCam.gameObject.SetActive(true);
        cutscenePlayerCam.transform.position = playerAnimPos[posID].position;
        cutscenePlayerCam.transform.rotation = playerAnimPos[posID].rotation;

        isInCutscene = true;
    }
    
    public void StopPlayerCutsceneNoGeorge()
    {
        if (isInCutscene)
        {
            //GameManager.Instance.Assistant.transform.position = cutsceneEndPos.transform.position;
            player.transform.position = cutsceneEndPos.transform.position;
            player.transform.rotation = cutsceneEndPos.transform.rotation;
        }
        
        EventManager.Trigger("ChangeMovementState", true);
        EventManager.Trigger("OnCutsceneEvent", true);
        EventManager.Trigger("OnPPCalled", PPNames.BORDERCINEMATIC, false);

        //georgeDummy.SetActive(false);
        cutscenePlayerCam.transform.rotation = originalPlayerCamTransform.rotation;
        cutscenePlayerCam.gameObject.SetActive(false);

        GameManager.Instance.GetCamera().gameObject.SetActive(true);

        isInCutscene = false;
    }
    
    public void StopCutsceneEvent(object[] parameters)
    {
        StopCutscene();
        StopPlayerCutsceneWithGeorge();
    }

    public void OnLevelOver()
    {
        EventManager.Trigger("OnCutsceneEvent", true);
        EventManager.Trigger("OnPPCalled", PPNames.BORDERCINEMATIC, false);
        player.transform.position = cutsceneEndPos.transform.position;
        player.transform.rotation = cutsceneEndPos.transform.rotation;
        cutscenePlayerCam.transform.position = cutsceneEndPos.transform.position;
        cutscenePlayerCam.transform.rotation = cutsceneEndPos.transform.rotation;
        GameManager.Instance.NextScene();
    }
    
    public void FinalCutscene()
    {
        EventManager.Trigger("OnLevelFinished");
    }
}
