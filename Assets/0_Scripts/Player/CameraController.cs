using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class CameraController : MonoBehaviour
{
    private Camera _mainCamera;
    private Transform _actualCameraPos;
    private List<Transform> _cameraPositions = new List<Transform>();

    private float _cameraSens = 500;
    private float _cameraSpeeed = 10;

    [SerializeField] private float _maxYRot = 50, _minYRot = -50;

    private float _xRotation;
    private float _yRotation;

    Action cameraMovement = delegate { };

    void Awake()
    {
        Cursor.lockState = CursorLockMode.Locked;

        // Get Main Camera
        _mainCamera = Camera.main;

        // Get all the posible points for the camera
        Transform povParent = transform.Find("POVs");

        foreach (Transform child in povParent)
        {
            _cameraPositions.Add(child);
        }

        _actualCameraPos = _cameraPositions[0];
        _mainCamera.transform.position = _actualCameraPos.position;
        _mainCamera.transform.rotation = _actualCameraPos.rotation;

        _mainCamera.transform.parent = _actualCameraPos;
    }

    private void Update()
    {
        cameraMovement();
    }

    // Void for move the camera with an input
    public void MoveCamera(float xAxie, float yAxie)
    {
        _xRotation += xAxie * _cameraSens * Time.fixedDeltaTime;
        _yRotation += yAxie * -1 * _cameraSens * Time.fixedDeltaTime;

        _yRotation = Mathf.Clamp(_yRotation, _minYRot, _maxYRot);

        transform.rotation = Quaternion.Euler(new Vector3(0, _xRotation, 0));
        _actualCameraPos.localRotation = Quaternion.Euler(new Vector3(_yRotation, 0, 0));
    }

    // Translate camera from point to point
    public void StartTranslate(int state)
    {
        _cameraPositions[state].rotation = _actualCameraPos.rotation;
        _actualCameraPos = _cameraPositions[state];
        _mainCamera.transform.parent = _actualCameraPos;

        cameraMovement = TranslateCamera;
    }

    void TranslateCamera()
    {
        Vector3 dir = _actualCameraPos.position - _mainCamera.transform.position;
        dir.Normalize();
        _mainCamera.transform.position += dir * _cameraSpeeed * Time.deltaTime;

        if (Vector3.Distance(_mainCamera.transform.position, _actualCameraPos.position) < 0.1f)
        {
            _mainCamera.transform.position = _actualCameraPos.position;
            cameraMovement = delegate { };
        }
    }
}
