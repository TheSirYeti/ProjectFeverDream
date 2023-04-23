using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class NodeManager : MonoBehaviour
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
    
    public static NodeManager instance;

    private void Awake()
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

    public void CalculateNodePaths(object[] parameters)
    {
        StartCoroutine(DoLazyNodeCalculation());
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
