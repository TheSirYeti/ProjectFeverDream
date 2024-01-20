using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectSwapTrigger : MonoBehaviour
{
    [SerializeField] private List<GameObject> _objectsToEnable;
    [SerializeField] private List<GameObject> _objectsToDisable;
    
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player")
        {
            foreach (var obj in _objectsToEnable)
            {
                obj.SetActive(true);
            }
            
            foreach (var obj in _objectsToDisable)
            {
                obj.SetActive(false);
            }
        }
    }
}
