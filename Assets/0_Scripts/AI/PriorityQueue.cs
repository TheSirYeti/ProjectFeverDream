using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PriorityQueue
{
    private Dictionary<Node, float> _allNodes = new Dictionary<Node, float>();

    public void Put(Node key, float value)
    {
        if (_allNodes.ContainsKey(key)) _allNodes[key] = value;
        else _allNodes.Add(key, value);
    }
    public Node Get()
    {
        if (Count() == 0) 
            return null;

        Node n = null;
        foreach (var item in _allNodes)
        {
            if (n == null) n = item.Key;
            if (item.Value < _allNodes[n]) n = item.Key;
        }

        _allNodes.Remove(n);

        return n;
    }


    public int Count()
    {
        return _allNodes.Count;
    }
}
