using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class NodeManager : MonoBehaviour
{
    public GameObject nodeParent;
    public List<Node> nodes;
    public LayerMask nodeMask;
    public LayerMask inSightMask;
    public LayerMask wallMask;
    public static NodeManager instance;

    private void Awake()
    {
        nodes = nodeParent.GetComponentsInChildren<Node>().ToList();
        
        if (instance == null)
        {
            instance = this;
        }
        else Destroy(gameObject);
    }

    public int GetClosestNode(Transform t)
    {
        int index = 0;
        float minDistance = Mathf.Infinity;
        for (int i = 0; i < nodes.Count; i++)
        {
            float distance = Vector3.Distance(t.position, nodes[i].transform.position);
            Vector3 dirToTarget = nodes[i].transform.position - t.position;
            if (distance <= minDistance && !Physics.Raycast(t.position, dirToTarget, dirToTarget.magnitude, wallMask))
            {
                index = i;
                minDistance = distance;
            }
        }

        return index;
    }

    public void CalculateNodePaths(object[] parameters)
    {
        StartCoroutine(DoLazyNodeCalculation());
    }
 
    IEnumerator DoLazyNodeCalculation()
    {
        int counter = 0;
        string nodesToSend = "";
        for(int i = 0; i < nodes.Count; i++)
        {
            for(int j = i + 1; j < nodes.Count; j++)
            {
                if (nodes[i] != nodes[j])
                {
                    nodesToSend = "";
                    nodesToSend += i + "," + j;
                    PathfindingTable.instance.GetPath(nodesToSend);

                    counter++;
                    if (counter >= 5)
                    {
                        counter = 0;
                        yield return new WaitForEndOfFrame();
                    }
                }
            }
        }
    }
}
