using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TutorialHelp : MonoBehaviour
{
    [SerializeField] private GameObject rotatingSign;
    [SerializeField] private Vector3 rotationAmount;
    [SerializeField] private float rotationTime;
    [Space(20)] [SerializeField] private int tutorialID;

    private void Start()
    {
        StartCoroutine(DoSignRotation());
    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            EventManager.Trigger("OnTutorialTriggered", tutorialID);
        }
    }

    /*private void OnTriggerExit(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            EventManager.Trigger("OnTutorialExit");
        }
    }*/

    IEnumerator DoSignRotation()
    {
        while (true)
        {
            LeanTween.rotateY(rotatingSign, 180f, rotationTime / 2);
            yield return new WaitForSeconds(rotationTime / 2);
            LeanTween.rotateY(rotatingSign, 360f, rotationTime / 2);
            yield return new WaitForSeconds(rotationTime / 2);
        }
    }
}
