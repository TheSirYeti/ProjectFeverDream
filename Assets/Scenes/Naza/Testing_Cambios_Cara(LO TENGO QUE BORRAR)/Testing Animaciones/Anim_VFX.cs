using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Anim_VFX : MonoBehaviour
{
    public Animator anim;
    public ParticleSystem slash;

    void Update()
    {
        if (Input.GetButtonDown("Fire1"))
        {
            anim.SetTrigger("Attack");
        }
    }

    void slashActivc()
    {
        slash.Play();
    }
}
