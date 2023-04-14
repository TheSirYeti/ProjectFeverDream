using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectPool
{
    public List<GameObject> objectPoolCollection = new List<GameObject>();
    [SerializeField] private GameObject[] prefabsList = new GameObject[1];


    public ObjectPool(GameObject prefabs, int ammountOfObjects)
    {
        objectPoolCollection.Clear();

        prefabsList[0] = prefabs;

        if (prefabsList.Length <= 1)
            InstantiateObjects(ammountOfObjects);
        else
            InstantiateRandomObjects(ammountOfObjects);
    }

    void InstantiateObjects(int objectPoolAmount)
    {
        GameObject newObject = null;

        for (int i = 0; i < objectPoolAmount; i++)
        {
            if (newObject == null)
            {
                newObject = GameObject.Instantiate(prefabsList[0]);
                newObject.name = $"{prefabsList[0].name}-{i}";
            }
            else
            {
                newObject = GameObject.Instantiate(newObject);
                newObject.name = $"{prefabsList[0].name}-{i}";
            }

            //newObject.transform.parent = this.transform;
            objectPoolCollection.Add(newObject);
            newObject.SetActive(false);
        }
    }

    void InstantiateRandomObjects(int objectPoolAmount)
    {
        int actualIndex = 0;

        for (int i = 0; i < objectPoolAmount; i++)
        {
            GameObject newObject = GameObject.Instantiate(prefabsList[actualIndex]);
            newObject.name = $"{prefabsList[actualIndex].name}-{i}";
            //newObject.transform.parent = this.transform;

            objectPoolCollection.Add(newObject);
            newObject.SetActive(false);

            actualIndex++;
            if (actualIndex >= prefabsList.Length)
                actualIndex = 0;
        }
    }

    public GameObject GetObject(Vector3 position, bool random = false)
    {
        GameObject newItem;

        if (objectPoolCollection.Count == 0) newItem = GameObject.Instantiate(prefabsList[Random.Range(0, prefabsList.Length)]);
        else
        {
            int index = 0;

            if (random)
                index = Random.Range(0, objectPoolCollection.Count);

            newItem = objectPoolCollection[index];
            objectPoolCollection.RemoveAt(index);
        }

        newItem.transform.position = position;
        newItem.SetActive(true);

        return newItem;
    }

    public void ReturnObject(GameObject item)
    {
        item.SetActive(false);
        objectPoolCollection.Add(item);
    }
}
