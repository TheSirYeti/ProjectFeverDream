using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

[CreateAssetMenu(fileName = "GenericScene", menuName = "ScriptableObjects/Scene")]
public class SO_Scene : ScriptableObject
{
    [FormerlySerializedAs("_unityScenes")] public List<SceneReference> unityScenes;
    public SO_AudioSet mySFX;
    public SO_AudioSet myMusic;
}
