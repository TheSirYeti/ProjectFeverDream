using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class MNode : MonoBehaviour
{
    [SerializeField] private List<MNode> _neighbors = new List<MNode>();
    
    private float _weigth = 0;
    public MNode _previouseNode = null;
    public Color nodeColor;

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
        if (_neighbors.Contains(neighbor)) return true;

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

    public MNode GetNeighbor(int index)
    {
        return _neighbors[index];
    }
    
    public int NeighboursCount()
    {
        return _neighbors.Count;
    }

    public void SetWeight(float weitgh)
    {
        _weigth = weitgh;
    }

    public float GetWeight()
    {
        return _weigth;
    }

    public void ResetNode()
    {
        _weigth = 0;
        _previouseNode = null;
        nodeColor = Color.blue;
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
        Gizmos.color = nodeColor;
        Gizmos.DrawWireSphere(transform.position, 0.2f);

        Gizmos.color = Color.yellow;
        if(_previouseNode)
            Gizmos.DrawLine(transform.position, _previouseNode.transform.position);
    }
}