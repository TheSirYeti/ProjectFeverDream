using UnityEngine;
using System.Collections;
using UnityEditor;
 
[CustomEditor(typeof(CopyAnimationPos))]
public class CopyTransBuilderEditor : Editor
{
    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();
 
        CopyAnimationPos myScript = (CopyAnimationPos)target;
        if (GUILayout.Button("Copy Transform"))
        {
            myScript.TransformThis();
        }
    }
}