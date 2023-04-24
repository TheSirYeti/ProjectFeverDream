using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;

public class CameraController : MonoBehaviour
{
    Model _model;

    private Camera _mainCamera;
    private Transform _mainCameraParent;

    private Transform _actualCameraPos;
    private List<Transform> _cameraPositions = new List<Transform>();

    [SerializeField] private float _cameraSens = 500;
    private float _cameraSpeeed = 10;

    [SerializeField] float _walkingFOV;
    [SerializeField] float _runningFOV;
    float _actualFOV;

    bool _isLargeFOV = false;

    //Shake Vars
    Vector3 _initialCamPos;
    bool _isShaking = false;
    float _shakeDuration = 0f;
    float _shakeMagnitude = 0.7f;
    float _dampingSpeed = 1.0f;

    // Camera bobbing variables
    bool _isBobbing = false;
    float _bobbingSpeed = 0.18f;
    float _bobbingAmount = 0.2f;
    float _timer = 0.0f;


    [SerializeField] private float _maxYRot = 50, _minYRot = -50;

    private float _xRotation;
    private float _yRotation;

    Action cameraMovement = delegate { };
    Action cameraEffects = delegate { };

    void Awake()
    {
        EventManager.Subscribe("CameraShake", ShakeState);
        EventManager.Subscribe("CameraBobbing", SetBobbing);

        _model = GetComponent<Model>();

        Cursor.lockState = CursorLockMode.Locked;

        // Get Main Camera
        _mainCamera = Camera.main;
        _mainCameraParent = Camera.main.transform.parent;

        // Get all the posible points for the camera
        Transform povParent = transform.Find("POVs");

        foreach (Transform child in povParent)
        {
            _cameraPositions.Add(child);
        }

        _actualCameraPos = _cameraPositions[0];
        _mainCameraParent.transform.position = _actualCameraPos.position;
        _mainCameraParent.transform.rotation = _actualCameraPos.rotation;

        _mainCameraParent.transform.parent = _actualCameraPos;

        _actualFOV = _walkingFOV;

        _initialCamPos = _mainCamera.transform.localPosition;
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
        cameraEffects();
    }

    #region Camera Move
    // Void for move the camera with an input
    public void MoveCamera(float xAxie, float yAxie)
    {
        _xRotation += xAxie * _cameraSens * Time.deltaTime;
        _yRotation += yAxie * -1 * _cameraSens * Time.deltaTime;

        _yRotation = Mathf.Clamp(_yRotation, _minYRot, _maxYRot);

        transform.rotation = Quaternion.Euler(new Vector3(0, _xRotation, 0));
        _actualCameraPos.localRotation = Quaternion.Euler(new Vector3(_yRotation, 0, 0));
    }
    #endregion

    #region Change Camera Spot
    // Translate camera from point to point
    public void StartTranslate(int state)
    {
        _cameraPositions[state].rotation = _actualCameraPos.rotation;
        _actualCameraPos = _cameraPositions[state];
        _mainCameraParent.transform.parent = _actualCameraPos;

        cameraMovement = TranslateCamera;
    }

    void TranslateCamera()
    {
        Vector3 dir = _actualCameraPos.position - _mainCameraParent.transform.position;
        dir.Normalize();
        _mainCameraParent.transform.position += dir * _cameraSpeeed * Time.deltaTime;

        if (Vector3.Distance(_mainCameraParent.transform.position, _actualCameraPos.position) < 0.1f)
        {
            _mainCameraParent.transform.position = _actualCameraPos.position;
            _initialCamPos = _mainCamera.transform.localPosition;
            cameraMovement = delegate { };
        }
    }
    #endregion

    #region Fov
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
    #endregion

    #region Sens
    // Change Sens
    void ChangeSens(params object[] parameters)
    {
        _cameraSens = (float)parameters[0];
        PlayerPrefs.SetFloat("Sensibilidad", (float)parameters[0]);
    }
    #endregion

    public void ShakeState(params object[] parameter)
    {
        if ((bool)parameter[0] && !_isShaking)
        {
            _isShaking = true;
            cameraEffects += CameraShake;
            SetShake();
        }
        else if ((bool)parameter[0] && _isShaking)
            SetShake();
        else if (!(bool)parameter[0] && _isShaking)
            cameraEffects -= CameraShake;
    }

    void SetShake(float duration = 0.2f)
    {
        _shakeDuration = duration;
    }

    void CameraShake()
    {
        _mainCamera.transform.localPosition = _initialCamPos + UnityEngine.Random.insideUnitSphere * _shakeMagnitude;

        _shakeDuration -= Time.deltaTime * _dampingSpeed;

        if (_shakeDuration <= 0)
        {
            _shakeDuration = 0f;
            _mainCamera.transform.localPosition = _initialCamPos;
            _isShaking = false;
            cameraEffects -= CameraShake;
        }
    }

    void SetBobbing(params object[] parameter)
    {
        if ((bool)parameter[0] && !_isBobbing)
        {
            _isBobbing = true;
            cameraEffects += CameraBobbing;
        }
        else if (!(bool)parameter[0] && _isBobbing)
        {
            _isBobbing = false;

            Vector3 pos = _mainCamera.transform.localPosition;
            pos.y = _initialCamPos.y;
            _mainCamera.transform.localPosition = pos;

            cameraEffects -= CameraBobbing;
        }
    }

    void CameraBobbing()
    {
        float waveslice = Mathf.Sin(_timer);
        _timer += _bobbingSpeed;

        if (_timer > Mathf.PI * 2)
        {
            _timer = _timer - (Mathf.PI * 2);
        }

        if (waveslice != 0)
        {
            float translateChange = waveslice * _bobbingAmount;
            float totalAxes = 1 + 1;
            totalAxes = Mathf.Clamp(totalAxes, 0.0f, 1.0f);
            translateChange *= totalAxes;
            Vector3 pos = _mainCamera.transform.localPosition;
            pos.y = _initialCamPos.y + translateChange;
            _mainCamera.transform.localPosition = pos;
        }
        else
        {
            Vector3 pos = _mainCamera.transform.localPosition;
            pos.y = _initialCamPos.y;
            _mainCamera.transform.localPosition = pos;
        }
    }
}
