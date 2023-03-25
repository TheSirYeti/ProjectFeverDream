using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class CameraController : MonoBehaviour
{
    private Camera _mainCamera;
    private Transform _actualCameraPos;
    private List<Transform> _cameraPositions = new List<Transform>();

    private float _cameraSpeed = 500;

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

    // Void for move the camera with an input
    public void MoveCamera(float xAxie, float yAxie)
    {
        _xRotation += xAxie * _cameraSpeed * Time.fixedDeltaTime;
        _yRotation += yAxie * -1 * _cameraSpeed * Time.fixedDeltaTime;

        _yRotation = Mathf.Clamp(_yRotation, _minYRot, _maxYRot);

        transform.rotation = Quaternion.Euler(new Vector3(0, _xRotation, 0));
        _actualCameraPos.localRotation = Quaternion.Euler(new Vector3(_yRotation, 0, 0));
    }

    // Translate camera from point to point
    void TranslateCamera()
    {

    }
}
