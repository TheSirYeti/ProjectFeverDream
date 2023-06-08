using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(MPathfinding))]
public class PathfindingTester : Editor
{
    public MPathfinding pathfinding;
    
    private void OnEnable()
    {
        pathfinding = (MPathfinding)target;
    }
    
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();
 
        // if(GUILayout.Button("Test Path"))
        // {
        //     pathfinding.TestFunc();
        // }
        // if(GUILayout.Button("Clear Nodes"))
        // {
        //     pathfinding.ClearNodes();
        // }
    }
}
