using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Serialization;

public class MNode : MonoBehaviour, IWeighted
{
    [FormerlySerializedAs("_neighbors")] [SerializeField] public List<MNode> neighbors = new();

    private float _weight = 0;
    public MNode previousNode = null;
    public Color nodeColor;

    public void AddNeighbor(MNode neighbor)
    {
        if (neighbor && !neighbors.Contains(neighbor))
        {
            
            neighbors.Add(neighbor);
        }
    }

    public void RemoveNeighbor(MNode neighbor)
    {
        var index = neighbors.IndexOf(neighbor);
        neighbors.RemoveAt(index);
    }

    public bool CheckNeighbor(MNode neighbor)
    {
        return neighbors.Contains(neighbor);
    }

    public void ClearNeighbours()
    {
        neighbors = new List<MNode>();
    }

    public bool HasNeighbours()
    {
        return neighbors.Count > 0;
    }

    public MNode GetNeighbor(int index)
    {
        return neighbors[index];
    }

    public int NeighboursCount()
    {
        return neighbors.Count;
    }

    public void SetWeight(float weigth)
    {
        _weight = weigth;
    }

    public void ResetNode()
    {
        _weight = 0;
        previousNode = null;
    }

    public void DestroyNode()
    {
        foreach (var t in neighbors)
        {
            t.RemoveNeighbor(this);
        }
    }
    
    
    public bool isOnPath = false;
    
    private void OnDrawGizmos()
    {
        Gizmos.color = isOnPath? Color.yellow : Color.green;
        Gizmos.DrawWireSphere(transform.position, 0.2f);

        // if (isOnPath)
        // {
        //     Gizmos.color = Color.red;
        //     Gizmos.DrawLine(transform.position, previousNode.transform.position);
        // }

        // Gizmos.color = Color.red;
        // if (_neighbors.Any())
        // {
        //     foreach (var neighbor in _neighbors)
        //     {
        //         Gizmos.DrawLine(transform.position, neighbor.transform.position);
        //     }
        // }


        // Gizmos.color = Color.yellow;
        // if (previousNode)
        //     Gizmos.DrawLine(transform.position, previousNode.transform.position);
    }

    public float Weight => _weight;
}