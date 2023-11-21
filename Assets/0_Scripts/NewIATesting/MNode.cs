using System.Collections.Generic;
using System.Linq;
using UnityEngine;
using UnityEngine.Serialization;

public class MNode : MonoBehaviour, IWeighted
{
    [SerializeField] private List<MNode> _neighbors = new List<MNode>();

    private float _weight = 0;
    public MNode previousNode = null;
    public Color nodeColor;

    public void AddNeighbor(MNode neighbor)
    {
        if (neighbor && !_neighbors.Contains(neighbor))
        {
            
            _neighbors.Add(neighbor);
        }
    }

    public void RemoveNeighbor(MNode neighbor)
    {
        var index = _neighbors.IndexOf(neighbor);
        _neighbors.RemoveAt(index);
    }

    public bool CheckNeighbor(MNode neighbor)
    {
        return _neighbors.Contains(neighbor);
    }

    public void ClearNeighbours()
    {
        _neighbors = new List<MNode>();
    }

    public bool HasNeighbours()
    {
        return _neighbors.Count > 0;
    }

    public MNode GetNeighbor(int index)
    {
        return _neighbors[index];
    }

    public int NeighboursCount()
    {
        return _neighbors.Count;
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
        foreach (var t in _neighbors)
        {
            t.RemoveNeighbor(this);
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.green;
        Gizmos.DrawWireSphere(transform.position, 0.2f);

        Gizmos.color = Color.red;
        if (_neighbors.Any())
        {
            foreach (var neighbor in _neighbors)
            {
                Gizmos.DrawLine(transform.position, neighbor.transform.position);
            }
        }


        Gizmos.color = Color.yellow;
        if (previousNode)
            Gizmos.DrawLine(transform.position, previousNode.transform.position);
    }

    public float Weight => _weight;
}