using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class MNode : MonoBehaviour
{
    [SerializeField] private List<MNode> _neighbors = new List<MNode>();


    public void AddNeighbor(MNode neighbor)
    {
        _neighbors.Add(neighbor);
    }

    public void RemoveNeighbor(MNode neighbor)
    {
        int index = _neighbors.IndexOf(neighbor);
        _neighbors.RemoveAt(index);
    }

    public bool CheckNeighbor(MNode neighbor)
    {
        if(_neighbors.Contains(neighbor)) return true;

        return false;
    }

    public void ClearNeighbours()
    {
        _neighbors = new List<MNode>();
    }

    public bool HasNeighbours()
    {
        if (_neighbors.Count > 0)
            return true;

        return false;
    }

    public void DestroyNode()
    {
        for (int i = 0; i < _neighbors.Count; i++)
        {
            _neighbors[i].RemoveNeighbor(this);
        }
    }
    
    private void OnDrawGizmos()
    {
        Gizmos.color = Color.blue;
        Gizmos.DrawWireSphere(transform.position, 0.2f);

        Gizmos.color = Color.cyan;
        // foreach (var neighbor in _neighbors)
        // {
        //     Gizmos.DrawLine(transform.position, neighbor.transform.position);
        // }
    }
}
