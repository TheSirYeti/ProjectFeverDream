using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class PathfindingTable : MonoBehaviour
{
    public LookUpTable<string, List<Node>> pathTable;

    public static PathfindingTable instance;

    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
        }
        else
        {
            Debug.Log("There already was an instance of " + this + ". Destroying...");
            Destroy(gameObject);
        }

        pathTable = new LookUpTable<string, List<Node>>(ConstructPathThetaStar);
    }
    
    public List<Node> GetPath(string nodes)
    {
        return pathTable.Get(nodes);
    }

    public List<Node> ConstructPathThetaStar(string nodes)
    {
        string[] splitStringArray = nodes.Split(',');

        bool state = bool.Parse(splitStringArray[2]);

        Node startingNode, goalNode;
        if (state)
        {
            startingNode = NodeManager.instance.nodesAssistant[Int32.Parse(splitStringArray[0])];
            goalNode = NodeManager.instance.nodesAssistant[Int32.Parse(splitStringArray[1])];
        }
        else
        {
            startingNode = NodeManager.instance.nodesEnemy[Int32.Parse(splitStringArray[0])];
            goalNode = NodeManager.instance.nodesEnemy[Int32.Parse(splitStringArray[1])];
        }



        var path = new List<Node>();
        path = ConstructPathAStar(startingNode, goalNode);
        
        if (path != null && path.Any())
        {
            path.Reverse();
            int index = 0;

            while (index <= path.Count - 1)
            {
                int indexNextNext = index + 2;
                if (indexNextNext > path.Count - 1) break;
                if (InSight(path[index].transform.position, path[indexNextNext].transform.position))
                    path.Remove(path[index + 1]);
                else index++;

            }
        }
        return path;
    }

    public bool InSight(Vector3 start, Vector3 end)
    {
        Vector3 dir = end - start;

        return !Physics.Raycast(start, dir, dir.magnitude, NodeManager.instance.inSightMask);
    }

    public List<Node> ConstructPathAStar(Node startingNode, Node goalNode)
    {
        if (startingNode == null || goalNode == null)
            return default;

        PriorityQueue frontier = new PriorityQueue();
        frontier.Put(startingNode, 0);

        Dictionary<Node, Node> cameFrom = new Dictionary<Node, Node>();
        Dictionary<Node, int> costSoFar = new Dictionary<Node, int>();

        cameFrom.Add(startingNode, null);
        costSoFar.Add(startingNode, 0);
        
        while (frontier.Count() > 0)
        {
            Node current = frontier.Get();

            if (current == goalNode)
            {
                List<Node> path = new List<Node>();
                Node nodeToAdd = current;

                while (nodeToAdd != null)
                {
                    path.Add(nodeToAdd);
                    nodeToAdd = cameFrom[nodeToAdd];
                }

                return path;
            }

            
            foreach (var next in current.GetNeighbors())
            {
                int newCost = costSoFar[current] + next.cost;

                if (!costSoFar.ContainsKey(next) || newCost < costSoFar[next])
                {
                    if (costSoFar.ContainsKey(next))
                    {
                        costSoFar[next] = newCost;
                        cameFrom[next] = current;
                    }
                    else
                    {
                        cameFrom.Add(next, current);
                        costSoFar.Add(next, newCost);
                    }

                    float priority = newCost + Heuristic(next.transform.position, goalNode.transform.position);
                    frontier.Put(next, priority);
                }
            }
        }
        return default;
    }

    float Heuristic(Vector3 a, Vector3 b)
    {
        return Vector3.Distance(a, b);
    }
}
