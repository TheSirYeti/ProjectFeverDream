using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class WaypointGizmo : MonoBehaviour
{
    public float sphereSize = 0.25f;
    public Color color = Color.yellow;

    private void OnDrawGizmos()
    {
        Gizmos.color = color;
        Gizmos.DrawSphere(transform.position, sphereSize);
    }
}
