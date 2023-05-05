using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LoadSceneTrigger : MonoBehaviour
{
    void Start()
    {
        SceneLoader.instance.StartNewSceneLoad();
    }
}
