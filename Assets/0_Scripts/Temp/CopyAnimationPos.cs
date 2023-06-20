using System.Collections;
using System.Collections.Generic;
using UnityEngine;
 
public class CopyAnimationPos : MonoBehaviour
{
    public Transform obj01;
    public Transform obj02;
    Transform[] transforms01;
    Transform[] transforms02;
    int transLength01;
    int transLength02;
 
    private TransformData transformDataOfObj01; //TransformData is a class that store and transfer the transform from
    private TransformData transformDataOfObj02; // one object to another
 
    public void TransformThis()
    {
        transforms01 = obj01.GetComponentsInChildren<Transform>();
        transforms02 = obj02.GetComponentsInChildren<Transform>();
 
        transLength01 = transforms01.Length;
        transLength02 = transforms02.Length;
 
        if(transLength01 == transLength02) //MUST BE the same character with the same rigged structure
        {
         
            for (int i = 0; i <= transLength01; i++)
            {
                transformDataOfObj01 = new TransformData(transforms01[i].transform);
                transformDataOfObj01.ApplyTo(transforms02[i].transform);
            }
        }
        else
        {
            Debug.Log("Objects does not have the same childrens Length");
        }
 
 
    }
}
