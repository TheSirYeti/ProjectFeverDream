#if UNITY_EDITOR

using System;
using System.Collections;
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;
using System.Linq;

[ExecuteInEditMode]
public class NodesGenerator : MonoBehaviour
{
    [SerializeField] private Vector3 _area;
    [SerializeField] private float _nodeSize;
    private float _nodeDistance => _nodeSize * 2.5f;
    [SerializeField] private MNode _prefab;

    [SerializeField] private List<GameObject> _nodeList = new List<GameObject>();
    private HashSet<Vector3> _spawnedNodes = new HashSet<Vector3>();

    private float maxX => transform.position.x + _area.x / 2;
    private float minY => transform.position.y - _area.y / 2;

    private float minZ => transform.position.z - _area.z / 2;
    private float maxZ => minZ + _area.z;

    private int multiplyDir = -1;

    public void Generate()
    {
        _spawnedNodes = new HashSet<Vector3>();
        var actualStartRay = transform.position;
        actualStartRay.x -= _area.x / 2;
        actualStartRay.y += _area.y / 2;
        actualStartRay.z += _area.z / 2;

        MNode actualNode;
        var count = 0;
        while (actualStartRay.y >= minY)
        {
            actualStartRay.x = transform.position.x - (_area.x / 2);
            actualStartRay.z = transform.position.z + _area.z / 2;
            
            while (actualStartRay.x <= maxX)
            {
                var ray = new Ray(actualStartRay, Vector3.down);

                if (Physics.Raycast(ray, out var hit, Mathf.Infinity, LayerManager.LM_FLOOR))
                {
                    if (!Physics.Raycast(ray, (hit.point - actualStartRay).magnitude, LayerManager.LM_NODEOBSTACLE))
                    {
                        if (!_spawnedNodes.Contains(hit.point + Vector3.up * 0.2f))
                        {                       
                            actualNode = PrefabUtility.InstantiatePrefab(_prefab, transform) as MNode;
                            actualNode.gameObject.name += count;
                            actualNode.transform.position = hit.point + Vector3.up * 0.2f;
                            _spawnedNodes.Add(hit.point + Vector3.up * 0.2f);

                            _nodeList.Add(actualNode.gameObject);
                        }
                    }
                }

                float distance = _nodeDistance;
                distance *= multiplyDir;
                actualStartRay.z += distance;

                if (actualStartRay.z > maxZ || actualStartRay.z < minZ)
                {
                    actualStartRay.z -= distance;
                    multiplyDir *= -1;
                    actualStartRay.x += _nodeDistance;
                }

                count++;
            }
            
            multiplyDir = -1;
            actualStartRay.y -= 1;
        }
       

        multiplyDir = -1;
    }

    public void DeleteNodes()
    {
        if (!_nodeList.Any()) return;

        foreach (var node in _nodeList)
        {
            DestroyImmediate(node);
        }

        _nodeList = new List<GameObject>();
    }

    public void GenerateNeighbours()
    {
        foreach (var node in _nodeList.Select(actualNode => actualNode.GetComponent<MNode>()))
        {
            Undo.RecordObject(node, "SetNeighbours");
            node.ClearNeighbours();
        }

        for (var i = 0; i < 2; i++)
        {
            foreach (var actualNode in _nodeList.Select(actualNode => actualNode.GetComponent<MNode>()))
            {
                Undo.RecordObject(actualNode, "SetNeighbours");
                var neighbours =
                    Physics.OverlapSphere(actualNode.transform.position, _nodeDistance, LayerManager.LM_NODE);

                foreach (var neighbour in neighbours)
                {
                    var checkingNeighbour = neighbour.gameObject.GetComponent<MNode>();
                    
                    if (checkingNeighbour == actualNode) continue;

                    if (actualNode.CheckNeighbor(checkingNeighbour)) continue;

                    var dir = neighbour.transform.position - actualNode.transform.position;
                    var rayWallChecker = new Ray(actualNode.transform.position, dir);

                    if (Physics.Raycast(rayWallChecker, _nodeDistance, LayerManager.LM_WALL)) continue;

                    checkingNeighbour.AddNeighbor(actualNode);
                    actualNode.AddNeighbor(checkingNeighbour);
                }
                PrefabUtility.RecordPrefabInstancePropertyModifications(actualNode);
            }

            ClearNodes();
        }
    }

    private  void ClearNodes()
    {
        var nodesToDelete = new Queue<GameObject>();

        foreach (var node in _nodeList)
        {
            var colliders =
                Physics.OverlapSphere(node.transform.position, _nodeSize, LayerManager.LM_NODE).Select(x=>x.gameObject);
            
           var closestNodes = colliders.Where(x=>x != node && !nodesToDelete.Contains(x)).Select(x => x);
            
            var mNode = node.GetComponent<MNode>();
            
            if (Physics.CheckSphere(node.transform.position, _nodeSize, LayerManager.LM_NODEOBSTACLE) || !mNode.HasNeighbours() || closestNodes.Any())
            {
                nodesToDelete.Enqueue(node);
            }
        }

        while (nodesToDelete.Count > 0)
        {
            var node = nodesToDelete.Dequeue();
            _nodeList.Remove(node);
            node.GetComponent<MNode>().DestroyNode();

            DestroyImmediate(node);
        }

        _nodeList = _nodeList.Where(x => x != null).ToList();
    }

    public void RemoveNulls()
    {
        _nodeList = _nodeList.Where(x => x != null).ToList();
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.blue;
        Gizmos.DrawWireCube(transform.position, _area);
    }
}

#endif