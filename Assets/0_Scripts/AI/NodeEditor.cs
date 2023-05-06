using UnityEngine;
using UnityEditor;
using System.Linq;

//[CustomEditor(typeof(Node))]
public class NodeEditor //: Editor
{
    /*private static Node lastCreatedNode;

    [MenuItem("GameObject/A* Node", false, 10)]
    static void CreateNode(MenuCommand menuCommand)
    {
        GameObject newNodeObject = new GameObject("Node");
        Node newNode = newNodeObject.AddComponent<Node>();
        GameObjectUtility.SetParentAndAlign(newNodeObject, menuCommand.context as GameObject);
        Undo.RegisterCreatedObjectUndo(newNodeObject, "Create " + newNodeObject.name);

        if (lastCreatedNode != null)
        {
            newNode.neighbors.Add(lastCreatedNode);
            lastCreatedNode.neighbors.Add(newNode);
        }

        lastCreatedNode = newNode;
        Selection.activeObject = newNodeObject;
    }

    public override void OnInspectorGUI()
    {
        DrawDefaultInspector();

        Node node = (Node)target;
        if (GUILayout.Button("Calculate Nodes"))
        {
            node.CalculateNodes();
        }
    }*/
}
