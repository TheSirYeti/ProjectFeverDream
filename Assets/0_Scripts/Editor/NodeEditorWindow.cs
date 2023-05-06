using UnityEditor;
using UnityEngine;

public class NodeEditorWindow : EditorWindow
{
    private static Node lastCreatedNode;

    [MenuItem("Window/Node Editor")]
    public static void ShowWindow()
    {
        GetWindow<NodeEditorWindow>("Node Editor");
    }

    private void OnGUI()
    {
        if (GUILayout.Button("Create Next Node"))
        {
            CreateNextNode();
        }
    }

    private void CreateNextNode()
    {
        GameObject newNodeObject = new GameObject("Node");
        Node newNode = newNodeObject.AddComponent<Node>();

        if (lastCreatedNode != null)
        {
            newNodeObject.transform.position = lastCreatedNode.transform.position;
            newNode.neighbors.Add(lastCreatedNode);
            lastCreatedNode.neighbors.Add(newNode);
            newNode.nodesAssistant = lastCreatedNode.nodesAssistant;
            newNode.viewRadius = lastCreatedNode.viewRadius;
            newNode.gizmoViewRadius = lastCreatedNode.gizmoViewRadius;
            newNode.tempLayerMask = lastCreatedNode.tempLayerMask;
            newNode.cost = lastCreatedNode.cost;
        }

        lastCreatedNode = newNode;
        Selection.activeObject = newNodeObject;
    }
}