using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class PriorityQueue<T>
{
    private List<TObj<T>> orderList = new List<TObj<T>>();

    public void Enqueue(TObj<T> obj)
    {
        orderList.Add(obj);
        //orderList.Sort();
    }

    public T Dequeue()
    {
        TObj<T> obj = orderList[0];
        orderList.Remove(obj);
        return obj.myObj;
    }

    public int Count()
    {
        return orderList.Count;
    }
}

public class TObj<T> : IComparable<TObj<T>>
{
    public T myObj;
    public float myWeight;

    public int CompareTo(TObj<T> other)
    {
        if (other == null) return 1;

        return Comparer<float>.Default.Compare(this.myWeight, other.myWeight);
    }
}