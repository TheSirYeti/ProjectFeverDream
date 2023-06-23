#if UNITY_EDITOR

using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using UnityEditor.SceneManagement;

[CustomEditor(typeof(NodesGenerator))]
public class GeneratorEditor : Editor
{
    public NodesGenerator _nodesGenerator;
    
    private void OnEnable()
    {
        _nodesGenerator = (NodesGenerator)target;
    }
    
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();
 
        if(GUILayout.Button("Generate Nodes"))
        {
            _nodesGenerator.Generate();
            EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
        }
        if(GUILayout.Button("Set & Check Nodes"))
        {
            _nodesGenerator.GenerateNeighbours();
            EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
        }
        if(GUILayout.Button("Destroy ALL Nodes"))
        {
            _nodesGenerator.DeleteNodes();
            EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
        }
        if(GUILayout.Button("Clear nulls"))
        {
            _nodesGenerator.RemoveNulls();
            EditorSceneManager.MarkSceneDirty(EditorSceneManager.GetActiveScene());
        }
    }
}

#endif
