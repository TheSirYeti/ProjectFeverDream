using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TempNextScene : GenericObject
{
    public int nextScene;
    
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    /*public override void OnStart()
    {
        TriggerNextScene(nextScene);
    }*/

    public void TriggerNextScene(int nextScene)
    {
        GameManager.Instance.NextScene();
    }

    public void TriggerMenu()
    {
        GameManager.Instance.ChangeScene(2);
    }

    private void OnEnable()
    {
        GameManager.Instance.ChangeScene(nextScene);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            GameManager.Instance.ChangeScene(nextScene);
        }
    }
}
