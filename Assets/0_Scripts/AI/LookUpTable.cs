using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LookUpTable<TInput, TResult>
{
    private Dictionary<TInput, TResult> _values = new Dictionary<TInput, TResult>();
    
    
    private Func<TInput, TResult> _process;

    public LookUpTable(Func<TInput, TResult> _process)
    {
        this._process = _process;
    }

    public TResult Get(TInput input)
    {
        if (_values.ContainsKey(input))
        {
            return _values[input];
        }
        else
        {
            var value = _process(input);
            if(value != null)
                _values.Add(input, value);
            return value;
        }
    }
}