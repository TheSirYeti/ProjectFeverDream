using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEditor;

public class Node : MonoBehaviour
{
    public float viewRadius;
    public List<Node> neighbors = new List<Node>();

    public int cost = 1;

    private void Start()
    {
        foreach (Node node in NodeManager.instance.nodes)
        {
            if (Vector3.Distance(node.transform.position, transform.position) <= viewRadius && node != this)
            {
                Vector3 dir = node.transform.position - transform.position;
                if (!Physics.Raycast(transform.position, dir, viewRadius, NodeManager.instance.wallMask))
                {
                    neighbors.Add(node);
                }
            }
        }
    }
    public List<Node> GetNeighbors()
    {
        return neighbors;
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;
        Gizmos.DrawSphere(transform.position, 0.25f);
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(transform.position, viewRadius);
    }
}
