﻿using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using TMPro;
using UnityEditor;

public class Node : MonoBehaviour
{
    public bool nodesAssistant;
    public float viewRadius;
    public float gizmoViewRadius;
    public List<Node> neighbors = new List<Node>();


    public int cost = 1;

    private void Start()
    {
        if (nodesAssistant)
        {
            foreach (Node node in NodeManager.instance.nodesAssistant)
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
        else
        {
            foreach (Node node in NodeManager.instance.nodesEnemy)
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
    }
    public List<Node> GetNeighbors()
    {
        return neighbors;
    }

    private void OnDrawGizmos()
    {
        if (nodesAssistant)
            Gizmos.color = Color.green;
        else
            Gizmos.color = Color.red;

        Gizmos.DrawSphere(transform.position, gizmoViewRadius);

        if (neighbors.Any())
        {
            foreach (var node in neighbors)
            {
                Gizmos.DrawLine(transform.position, node.transform.position);
            }
        }
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(transform.position, viewRadius);
    }
}
