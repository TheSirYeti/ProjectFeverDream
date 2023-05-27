using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class NodeManager : GenericObject
{
    [Header("Node Parents")]
    [SerializeField] private GameObject nodeEnemyParent;
    public List<Node> nodesEnemy;
    [Space(10)]
    [SerializeField] private GameObject nodeAssistantParent;
    public List<Node> nodesAssistant;
    
    [Header("Layers")]
    public LayerMask nodeMask;
    public LayerMask inSightMask;
    public LayerMask wallMask;

    [Header("Extra Properties")] 
    [SerializeField] private float escapeViewRadius;
    public static NodeManager instance;

    public override void OnAwake()
    {
        nodesEnemy = nodeEnemyParent.GetComponentsInChildren<Node>().ToList();
        nodesAssistant = nodeAssistantParent.GetComponentsInChildren<Node>().ToList();
        
        if (instance == null)
        {
            instance = this;
        }
        else Destroy(gameObject);
    }

    public int GetClosestNode(Transform t, bool isForAssistant = false)
    {
        List<Node> nodesToUse = new List<Node>();
        
        if(isForAssistant)
            nodesToUse = nodesAssistant;
        else nodesToUse = nodesEnemy;

        int index = 0;
        float minDistance = Mathf.Infinity;
        for (int i = 0; i < nodesToUse.Count; i++)
        {
            float distance = Vector3.Distance(t.position, nodesToUse[i].transform.position);
            Vector3 dirToTarget = nodesToUse[i].transform.position - t.position;
            if (distance <= minDistance && !Physics.Raycast(t.position, dirToTarget, dirToTarget.magnitude, wallMask))
            {
                index = i;
                minDistance = distance;
            }
        }

        return index;
    }
    
    public int GetEscapeNode(Transform t, bool isForAssistant = false)
    {
        List<Node> nodesToUse = new List<Node>();
        Collider[] nearbyNodes = Physics.OverlapSphere(t.position, escapeViewRadius, nodeMask);

        if (!nearbyNodes.Any()) return 0;

        foreach (var col in nearbyNodes)
        {
            Debug.Log(col.gameObject.name);
        }
        
        var filteredNodes = nearbyNodes
            .Where(x => x.gameObject.GetComponent<Node>().nodesAssistant == isForAssistant)
            .ToList();
        
        foreach (var node in filteredNodes)
        {
            nodesToUse.Add(node.gameObject.GetComponent<Node>());
        }

        if (!nodesToUse.Any()) return 0;

        int index = 0;
        float maxDistance = -1;
        for (int i = 0; i < nodesToUse.Count; i++)
        {
            float distance = Vector3.Distance(t.position, nodesToUse[i].transform.position);
            Vector3 dirToTarget = nodesToUse[i].transform.position - t.position;
            if (distance >= maxDistance && !Physics.Raycast(t.position, dirToTarget, dirToTarget.magnitude, wallMask))
            {
                index = i;
                maxDistance = distance;
            }
        }

        return index;
    }

    public void CalculateNodePaths(object[] parameters)
    {
        StartCoroutine(DoLazyNodeCalculation());
    }

    public Node GetNode(int id, bool isForAssistant)
    {
        List<Node> nodes = new List<Node>();
        
        if (isForAssistant)
            nodes = nodesAssistant;
        else nodes = nodesEnemy;

        return nodes[id];
    }
 
    IEnumerator DoLazyNodeCalculation()
    {
        int counter = 0;
        string nodesToSend = "";
        for(int i = 0; i < nodesEnemy.Count; i++)
        {
            for(int j = i + 1; j < nodesEnemy.Count; j++)
            {
                if (nodesEnemy[i] != nodesEnemy[j])
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
