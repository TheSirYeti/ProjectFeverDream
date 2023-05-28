using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class PriorityQueue<T>
{
    private Queue<TObj> priorityQueue = new Queue<TObj>();

    private List<TObj> orderList = new List<TObj>();

    struct TObj
    {
        public T myObj;
        public int myWeight;
    }

    public void Enqueue(T obj, int weight)
    {
        TObj t = new TObj();
        t.myObj = obj;
        t.myWeight = weight;

        orderList = priorityQueue.ToList();
        
        orderList.Add(t);
        orderList = orderList.OrderBy(x => x.myWeight).ToList();

        priorityQueue = new Queue<TObj>();
        
        foreach (var listObj in orderList)
        {
            priorityQueue.Enqueue(listObj);
        }
    }

    public T Dequeue()
    {
        TObj obj = priorityQueue.Dequeue();
        orderList.Remove(obj);
        return obj.myObj;
    }

    public int Count()
    {
        return priorityQueue.Count;
    }
}
