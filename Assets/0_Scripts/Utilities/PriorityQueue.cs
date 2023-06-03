using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System.Linq;

public class PriorityQueue<T>
{
    private List<TObj> orderList = new List<TObj>();

    struct TObj
    {
        public T myObj;
        public float myWeight;
    }

    public void Enqueue(T obj, float weight)
    {
        TObj t = new TObj();
        t.myObj = obj;
        t.myWeight = weight;

        orderList.Add(t);
        orderList = orderList.OrderBy(x => x.myWeight).ToList();
    }

    public T Dequeue()
    {
        TObj obj = orderList[0];
        orderList.Remove(obj);
        return obj.myObj;
    }

    public int Count()
    {
        return orderList.Count;
    }
}
