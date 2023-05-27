using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class VFXManager : GenericObject
{
    [SerializeField] List<ParticleSystem> _fullBaggeteSlice;
    [SerializeField] List<ParticleSystem> _brokenBaggeteSlice;

    [SerializeField] List<ParticleSystem> _toasterParticles;

    [SerializeField] ParticleSystem _bagguetHit;
    
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }
    
    public override void OnAwake()
    {
        EventManager.Subscribe("VFX_FullSlice", FullSlice);
        EventManager.Subscribe("VFX_BrokenSlice", BrokenSlice);
        EventManager.Subscribe("VFX_BaggueteHit", BagguetsHitEffect);
        EventManager.Subscribe("VFX_ToasterON", ToasterVFX_ON);
        EventManager.Subscribe("VFX_ToasterOFF", ToasterVFX_OFF);

        _bagguetHit.transform.parent = null;
    }

    void FullSlice(params object[] parameters)
    {
        _fullBaggeteSlice[(int)parameters[0]].Play();
    }

    void BrokenSlice(params object[] parameters)
    {
        _brokenBaggeteSlice[(int)parameters[0]].Play();
    }

    void BagguetsHitEffect(params object[] parameters)
    {
        Transform newParticlePos = (Transform)parameters[0];
        _bagguetHit.transform.position = newParticlePos.position;
        _bagguetHit.transform.rotation = newParticlePos.rotation;

        _bagguetHit.Play();
    }

    void ToasterVFX_ON(params object[] parameters)
    {
        _toasterParticles[(int)parameters[0]].Play();
    }

    void ToasterVFX_OFF(params object[] parameters)
    {
        _toasterParticles[(int)parameters[0]].Stop();
    }
}
