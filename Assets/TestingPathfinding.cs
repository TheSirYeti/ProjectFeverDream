using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class TestingPathfinding : MonoBehaviour
{
    [SerializeField] private Transform _target;

    private static List<MNode> actualNodes = new List<MNode>();

    [ContextMenu("Test PF")]
    public void CalculatePathfinding()
    {
        MPathfinding.instance.RequestPath(transform.position, _target.position, SuccesCallBack, FailCallBack);
    }

    private Action<Path> SuccesCallBack = (path) =>
    {
        if (actualNodes.Any())
        {
            foreach (var node in actualNodes)
            {
                node.isOnPath = false;
            }
        }

        actualNodes.Clear();
        Debug.Log("--------------------Success--------------------");

        while (path.AnyInPath())
        {
            var nextNode = path.GetNextNode();

            nextNode.isOnPath = true;
            actualNodes.Add(nextNode);
            Debug.Log(nextNode.gameObject.name);
        }
    };

    private Action FailCallBack = () => { Debug.Log("Fail"); };
}