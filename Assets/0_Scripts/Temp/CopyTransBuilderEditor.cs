using UnityEngine;
using System.Collections;
using UnityEditor;

#if UNITY_EDITOR
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
#endif