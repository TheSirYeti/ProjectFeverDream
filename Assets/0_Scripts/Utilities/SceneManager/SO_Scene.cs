using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;
using System;
using UnityEditor;

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
        public Color cameraColor;
        public bool isOrthographic;
        public float orthographicSize;
    }
}
