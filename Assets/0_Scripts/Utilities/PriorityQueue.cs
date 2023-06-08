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

        if (orderList.Count > 1)
        {
            var index = BinarySearch(weight);

            orderList.Insert(index, t);
        }
        else
        {
            orderList.Add(t);
        }
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

    int BinarySearch(float weight)
    {
        var min = 0;
        var max = orderList.Count - 1;

        var watchdog = 10000;

        while (min <= max && watchdog > 0)
        {
            watchdog--;
            
            if (watchdog < 1)
                Debug.Log("Watchdog time");

            if (min == max)
            {
                return min;
            }

            var mid = (min + max) / 2;

            if (weight < orderList[mid].myWeight)
            {
                max = mid - 1;
            }
            else if (weight > orderList[mid].myWeight)
            {
                min = mid + 1;
            }
        }

        return orderList.Count - 1;
    }
}