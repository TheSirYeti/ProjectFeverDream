using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class TempEnemyForPF : MonoBehaviour
{
    // TODO: Delte this script when i finish pf

    public Transform objective;
    private Vector3 _target;
    private Path _actualPath;
    private MNode _actualNode;
    public float speed;

    public LayerMask obstacleMask;

    private Action onUpdate = delegate { };

    void Start()
    {
        GetNewPath();
        _actualNode = _actualPath.GetNextNode();
        Debug.Log(_actualNode.name);
        //onUpdate = State_Path;
    }

    void Update()
    {
        if (Input.GetKeyDown(KeyCode.A))
        {
            GetNewPath();
        }

        if (Input.GetKeyDown(KeyCode.S))
        {
            onUpdate = State_Path;
        }

        onUpdate();
    }

    void State_Path()
    {
        Vector3 dir = (_actualNode.transform.position - transform.position).normalized;
        transform.position += dir * (speed * Time.deltaTime);

        if (Vector3.Distance(transform.position, _actualNode.transform.position) < 0.5f)
        {
            MNode node = _actualPath.GetNextNode();

            if (node)
                _actualNode = node;
            else
            {
                Debug.Log("llegue");
                onUpdate = delegate { };
            }
        }
    }

    void State_Chase()
    {
        Vector3 dir = _target - transform.position;
        transform.position += dir * (speed * Time.deltaTime);

        if (Vector3.Distance(transform.position, _target) < 0.5f)
        {
            Debug.Log("llegue");
            onUpdate = delegate { };
        }
    }

    void GetNewPath()
    {
        _actualPath = MPathfinding._instance.GetPath(transform.position, objective.position);
        _actualNode = _actualPath.GetNextNode();
    }

    public bool OnSight()
    {
        Vector3 dir = _target - transform.position;
        Ray ray = new Ray(transform.position, dir);

        if (!Physics.Raycast(ray, dir.magnitude, obstacleMask))
        {
            return true;
        }

        return false;
    }
}