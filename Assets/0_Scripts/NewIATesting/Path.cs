using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class Path
{
    private readonly Queue<MNode> _pathQueue = new Queue<MNode>();

    public void AddNode(MNode node)
    {
        _pathQueue.Enqueue(node);
    }

    public MNode GetNextNode()
    {
        return _pathQueue.Any() ? _pathQueue.Dequeue() : null;
    }

    public MNode CheckNextNode()
    {
        return _pathQueue.Any() ?  _pathQueue.Peek() : null;
    }

    public bool AnyInPath()
    {
        return _pathQueue.Any();
    }

    public int Count()
    {
        return _pathQueue.Count;
    }
}