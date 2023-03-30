using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class NodeManager : MonoBehaviour
{
    public List<Node> nodes;
    public LayerMask nodeMask;
    public LayerMask wallMask;
    public static NodeManager instance;

    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else Destroy(gameObject);
    }

    public int GetClosestNode(Transform t)
    {
        int index = -1;
        float minDistance = Mathf.Infinity;
        for (int i = 0; i < nodes.Count; i++)
        {
            float distance = Vector3.Distance(t.position, nodes[i].transform.position);
            Vector3 dirToTarget = nodes[i].transform.position - t.position;
            if (distance <= minDistance && !Physics.Raycast(transform.position, dirToTarget, dirToTarget.magnitude, wallMask))
            {
                index = i;
                minDistance = distance;
            }
        }

        return index;
    }
}
