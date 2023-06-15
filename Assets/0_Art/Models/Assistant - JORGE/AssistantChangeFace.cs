using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class AssistantChangeFace : MonoBehaviour
{
    [Header("Material & Mesh")]
    [SerializeField] private SkinnedMeshRenderer _mouthMesh;
    [SerializeField] private Material _assistantHeadMAT;

    [Header("BlendShape (NO PONGA DOS VARIABLES AL MISMO TIEMPO)")]
    [Range(0.0f, 100.0f)]
    [SerializeField] private float talking;
    [Range(0.0f, 100.0f)]
    [SerializeField] private float neutral;
    [Range(0.0f, 85.0f)]
    [SerializeField] private float angry;

    [Header("Control Shader")]
    [Range(0.0f, 5.0f)]
    [SerializeField] private int _controlFace;
    [Range(0.0f, 0.5f)]
    [SerializeField] private float _speedTalking;
    [Range(1.0f, 3.0f)]
    [SerializeField] private int _typeMouth = 1;

    [SerializeField] bool _noMesh = true;

    private void Start()
    {
        BlendShapeAndShader();
    }
    void Update()
    {
        BlendShapeAndShader();

        if (_noMesh == false)
            _mouthMesh.GetComponent<SkinnedMeshRenderer>().enabled = false;

        if (_noMesh == true)
            _mouthMesh.GetComponent<SkinnedMeshRenderer>().enabled = true;
    }

    void BlendShapeAndShader()
    {
        //Controladores del BlendShape
        _mouthMesh.SetBlendShapeWeight(0, angry);
        _mouthMesh.SetBlendShapeWeight(1, neutral);
        _mouthMesh.SetBlendShapeWeight(2, talking);

        //Controladores del Shader
        _assistantHeadMAT.SetFloat("_ControlFace", _controlFace);
        _assistantHeadMAT.SetFloat("_SpeedTalking", _speedTalking);
        _assistantHeadMAT.SetFloat("_TypeMouth", _typeMouth);
    }
}
