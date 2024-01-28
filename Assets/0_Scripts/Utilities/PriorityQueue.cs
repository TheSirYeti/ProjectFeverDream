using System.Collections.Generic;

public interface IWeighted
{
    float Weight { get; }
}

public class PriorityQueue<T> where T : IWeighted
{
    private List<T> _internal;

    public int Count => _internal.Count;
    public bool IsEmpty => _internal.Count == 0;

    public bool Contains(T item)
    {
        return _internal.Contains(item);
    }

    public PriorityQueue()
    {
        _internal = new List<T>();
    }

    public PriorityQueue(PriorityQueue<T> collection)
    {
        _internal = new List<T>(collection._internal);
    }

    public void Enqueue(T storeObject)
    {
        _internal.Add(storeObject);

        RunEnqueueRules(_internal.Count - 1);
    }

    public T Dequeue()
    {
        if (Count == 0) return default;

        var temp = _internal[0];
        _internal[0] = _internal[Count - 1];
        _internal.RemoveAt(Count - 1);

        RunDequeueRules(0);

        return temp;
    }

    public T Peek()
    {
        return Count == 0 ? default : _internal[0];
    }

    private void RunEnqueueRules(int index)
    {
        var parentIndex = GetParent(index);

        if (parentIndex == -1) return;

        if (_internal[index].Weight < _internal[parentIndex].Weight)
        {
            var temp = _internal[parentIndex];
            _internal[parentIndex] = _internal[index];
            _internal[index] = temp;
            RunEnqueueRules(parentIndex);
        }
    }

    private void RunDequeueRules(int index)
    {
        var leftChild = GetLeftDescendant(index);
        var rightChild = GetRightDescendant(index);

        if (leftChild == -1) return;
        if (rightChild == -1)
        {
            if (_internal[leftChild].Weight < _internal[index].Weight)
            {
                var temp = _internal[index];
                _internal[index] = _internal[leftChild];
                _internal[leftChild] = temp;
            }

            return;
        }

        var biggerChildIndex = _internal[leftChild].Weight < _internal[rightChild].Weight
            ? leftChild
            : rightChild;

        if (_internal[biggerChildIndex].Weight < _internal[index].Weight)
        {
            var temp = _internal[index];
            _internal[index] = _internal[biggerChildIndex];
            _internal[biggerChildIndex] = temp;
            RunDequeueRules(biggerChildIndex);
        }
    }

    private int GetParent(int index)
    {
        var value = (index - 1) / 2;
        return value >= 0 ? value : -1;
    }

    private int GetLeftDescendant(int index)
    {
        var value = (index * 2) + 1;
        return value < Count ? value : -1;
    }

    private int GetRightDescendant(int index)
    {
        var value = (index * 2) + 2;
        return value < Count ? value : -1;
    }

    public override string ToString()
    {
        string rString = "Elements Are: ";

        for (int i = 0; i < Count; i++)
        {
            rString += $"\n {i} - {_internal[i]}";
        }

        return rString;
    }
}