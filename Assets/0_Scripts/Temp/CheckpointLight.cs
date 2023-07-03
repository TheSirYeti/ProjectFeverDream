using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class CheckpointLight : MonoBehaviour
{
    [SerializeField] private List<Transform> _onLight = new List<Transform>();
    private void Awake()
    {
        Destroy(gameObject, 1f);
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.transform.tag == "Player")
        {
            for (int i = 0; i < _onLight.Count; i++)
            {
                _onLight[i].gameObject.SetActive(true);
            }
        }
    }
}
