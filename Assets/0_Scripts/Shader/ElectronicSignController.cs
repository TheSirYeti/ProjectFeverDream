using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

public class ElectronicSignController : GenericObject
{
    [SerializeField] private List<Texture> myPosters;
    [SerializeField] private Material posterMat;

    [SerializeField] private float timeEnabled;
    [SerializeField] private float timeToCycle;
    
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    public override void OnStart()
    {
        StartCoroutine(DoSignCycling());
    }

    private IEnumerator DoSignCycling()
    {
        while (true)
        {
            foreach (var poster in myPosters)
            {
                LeanTween.value(0, 1, timeToCycle).setOnUpdate((float value) =>
                {
                    posterMat.SetFloat("_NoiseValue", value);
                });
                yield return new WaitForSeconds(timeToCycle);
                posterMat.SetTexture("_Poster", poster);
                LeanTween.value(1, 0, timeToCycle).setOnUpdate((float value) =>
                {
                    posterMat.SetFloat("_NoiseValue", value);
                });
                yield return new WaitForSeconds(timeToCycle);

                yield return new WaitForSeconds(timeEnabled);
            }
        }
    }
}
