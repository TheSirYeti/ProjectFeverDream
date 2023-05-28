using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
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
        }
        if(GUILayout.Button("Destroy ALL Nodes"))
        {
            _nodesGenerator.DeleteNodes();
        }
        if(GUILayout.Button("Set Neighbours"))
        {
            _nodesGenerator.GenerateNeighbours();
        }
        if(GUILayout.Button("Clear Unusable Nodes"))
        {
            _nodesGenerator.ClearNodes();
        }
    }
}
