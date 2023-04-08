using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BaguetteSpawner : MonoBehaviour
{
    public GameObject baguettePrefab;
    public List<Transform> allSpawnPositions;
    private float maxValue = 360;
    private float minValue = 0;
    
    
    public void SpawnBaguettes()
    {
        SoundManager.instance.PlaySound(SoundID.BAGUETTE);
        foreach (var spawnPos in allSpawnPositions)
        {
            GameObject baguetteInstance = Instantiate(baguettePrefab);
            baguetteInstance.transform.position = spawnPos.position;
            baguetteInstance.transform.Rotate(
                Random.Range(minValue, maxValue + 1), 
                Random.Range(minValue, maxValue + 1),
                Random.Range(minValue, maxValue + 1));
        }
    }
}
