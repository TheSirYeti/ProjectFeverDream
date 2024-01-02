using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectToggleLooper : GenericObject
{
    [SerializeField] private List<GameObject> _objectList;
    [SerializeField] private float currentToggleTime, toggleTime;
    private int currentID = 0;
    private void Awake()
    {
       UpdateManager.instance.AddObject(this);
       currentToggleTime = 0;
    }

    public override void OnUpdate()
    {
        currentToggleTime -= Time.deltaTime;
        if (currentToggleTime <= 0)
        {
            currentToggleTime = toggleTime;
            
            foreach (var obj in _objectList)
            {
                obj.SetActive(false);
            }

            currentID++;
            if (currentID >= _objectList.Count)
                currentID = 0;

            _objectList[currentID].SetActive(true);
        }
    }
}
