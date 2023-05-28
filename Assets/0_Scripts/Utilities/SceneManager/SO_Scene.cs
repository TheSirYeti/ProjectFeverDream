using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;
using System;

[CreateAssetMenu(fileName = "GenericScene", menuName = "ScriptableObjects/Scene")]
public class SO_Scene : ScriptableObject
{
    [FormerlySerializedAs("_unityScenes")] public List<SceneReference> unityScenes;
    public SO_AudioSet mySFX;
    public SO_AudioSet myMusic;
    public bool hasLoadingScreen;
    public CameraSettings cameraSettings;
    
    [Serializable]
    public struct CameraSettings
    {
        public int newLayer;
        public CameraClearFlags clearFlag;
    }
}
