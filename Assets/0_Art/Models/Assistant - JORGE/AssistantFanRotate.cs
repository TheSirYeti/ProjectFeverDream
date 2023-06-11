using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AssistantFanRotate : MonoBehaviour
{
    [SerializeField] private Transform[] fanObject;
    [SerializeField] private float fanSpeed;

    void Update()
    {
        fanObject[0].transform.Rotate(new Vector3(0,fanSpeed,0));
        fanObject[1].transform.Rotate(new Vector3(0, -fanSpeed, 0));

        if (fanSpeed >= 360 && fanSpeed >= -360)
            fanSpeed = 0;
    }
}
