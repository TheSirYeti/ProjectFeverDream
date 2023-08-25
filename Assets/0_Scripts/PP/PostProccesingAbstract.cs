using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering.PostProcessing;

public abstract class PostProccesingAbstract: MonoBehaviour
{
    [Header("PostProcessing")]
    [SerializeField] protected PostProcessVolume _postProcessVolume;
    [SerializeField] protected bool _enabled = false;
    protected abstract void GeneralSettings();
    protected abstract void EffectEnabled(bool on);
}
