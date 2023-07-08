using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class TeaserCamBinds : MonoBehaviour
{
    public Animator animator;

    public void Update()
    {
        if (Input.GetKeyDown(KeyCode.Alpha1))
        {
            animator.Play("TeaserAnim 1");
        }
        
        if (Input.GetKeyDown(KeyCode.Alpha2))
        {
            animator.Play("TeaserAnim 2");
        }
        
        if (Input.GetKeyDown(KeyCode.Alpha3))
        {
            animator.Play("TeaserAnim 3");
        }
        
        if (Input.GetKeyDown(KeyCode.Alpha4))
        {
            animator.Play("TeaserAnim 4");
        }
    }
}
