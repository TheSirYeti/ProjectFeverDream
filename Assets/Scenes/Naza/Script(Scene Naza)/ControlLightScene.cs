using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UIElements;

public class ControlLightScene : MonoBehaviour
{
    [SerializeField] private List<Transform> _onLight = new List<Transform>();
    [SerializeField] private float _active = 0;
    [SerializeField] private bool _negative = false;

    [SerializeField] private Vector3 movePosition = Vector3.zero;
    private Vector3 originalPosition = Vector3.zero;

    private void Start()
    {
        originalPosition = transform.position;
    }

    private void OnTriggerEnter(Collider other)
    {
        if(_negative == false)
        {
            if (other.transform.tag == "Player" && _active == 0)
            {
                for (int i = 0; i < _onLight.Count; i++)
                {
                    _onLight[i].gameObject.SetActive(true);
                }

                _active = 1;
                transform.position = movePosition;

            }
            else if (other.transform.tag == "Player" && _active == 1)
            {
                for (int i = 0; i < _onLight.Count; i++)
                {
                    _onLight[i].gameObject.SetActive(false);
                }

                _active = 0;
                transform.position = originalPosition;
            }
        }

        if(_negative == true)
        {
            if (other.transform.tag == "Player" && _active == 0)
            {
                for (int i = 0; i < _onLight.Count; i++)
                {
                    _onLight[i].gameObject.SetActive(true);
                }

                _active = 1;
                transform.position = originalPosition;

            }
            else if (other.transform.tag == "Player" && _active == 1)
            {
                for (int i = 0; i < _onLight.Count; i++)
                {
                    _onLight[i].gameObject.SetActive(false);
                }

                _active = 0;
                transform.position = movePosition;
            }
        }


    }
}
