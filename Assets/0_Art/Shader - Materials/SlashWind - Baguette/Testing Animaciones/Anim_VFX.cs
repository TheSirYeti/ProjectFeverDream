using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class Anim_VFX : MonoBehaviour
{
    public Animator anim;
    public ParticleSystem slash, bread;

    void Update()
    {
        if (Input.GetButtonDown("Fire1"))
        {
            anim.SetTrigger("Attack");
            Debug.Log("Me llamo");
        }
    }

    void slashActivc()
    {
        slash.Play();
    }

    void traceBread()
    {
        bread.Play();
    }
}
