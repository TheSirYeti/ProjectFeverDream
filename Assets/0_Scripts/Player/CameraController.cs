using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class CameraController : MonoBehaviour
{
    Model _model;

    private Camera _mainCamera;
    private Transform _actualCameraPos;
    private List<Transform> _cameraPositions = new List<Transform>();

    [SerializeField] private float _cameraSens = 500;
    private float _cameraSpeeed = 10;

    [SerializeField] float _walkingFOV;
    [SerializeField] float _runningFOV;
    float _actualFOV;

    bool _isLargeFOV = false;


    [SerializeField] private float _maxYRot = 50, _minYRot = -50;

    private float _xRotation;
    private float _yRotation;

    Action cameraMovement = delegate { };

    void Awake()
    {
        _model = GetComponent<Model>();

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

        _actualFOV = _walkingFOV;
    }

    private void Start()
    {
        EventManager.Subscribe("ChangeSens", ChangeSens);

        if (PlayerPrefs.HasKey("Sensibilidad"))
            _cameraSens = PlayerPrefs.GetFloat("Sensibilidad");
    }

    private void Update()
    {
        cameraMovement();
    }

    // Void for move the camera with an input
    public void MoveCamera(float xAxie, float yAxie)
    {
        _xRotation += xAxie * _cameraSens * Time.deltaTime;
        _yRotation += yAxie * -1 * _cameraSens * Time.deltaTime;

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

    public void ChangeRunningFOV(int state)
    {
        if (_model.isCrouch && state == 1) return;

        if ((state == 0 && !_isLargeFOV) || (state == 1 && _isLargeFOV)) return;

        LeanTween.cancel(gameObject);

        if (state == 0)
        {
            _actualFOV = _walkingFOV;
            _isLargeFOV = false;
        }
        else if (state == 1)
        {
            _actualFOV = _runningFOV;
            _isLargeFOV = true;
        }

        LeanTween.value(_mainCamera.fieldOfView, _actualFOV, 0.15f).setOnUpdate((float value) =>
        {
            _mainCamera.fieldOfView = value;
        });
    }

    // Change Sens
    void ChangeSens(params object[] parameters)
    {
        _cameraSens = (float)parameters[0];
        PlayerPrefs.SetFloat("Sensibilidad", (float)parameters[0]);
    }
}
