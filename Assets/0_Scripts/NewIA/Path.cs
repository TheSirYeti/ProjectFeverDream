using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class Path
{
    public Queue<MNode> pathQueue = new Queue<MNode>();

    public void AddNode(MNode node)
    {
        pathQueue.Enqueue(node);
    }

    public MNode GetNextNode()
    {
        if (pathQueue.Count > 0)
            return pathQueue.Dequeue();
        else return null;
    }

    public MNode CheckNextNode()
    {
        if (!pathQueue.Any()) return null;
        
        return pathQueue.Peek();
    }

    public int PathCount()
    {
        return pathQueue.Count;
    }
}