using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "GenericScene", menuName = "ScriptableObjects/Scene")]
public class SO_Scene : ScriptableObject
{
    public List<SceneReference> _unityScenes;
}
