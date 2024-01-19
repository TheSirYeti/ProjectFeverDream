using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using UnityEngine.Serialization;

public class CameraController : GenericObject
{
    // Model
    Model _model;

    // Cameras & Positions
    Camera _camera;
    Camera _cameraGetter { get { if (_camera) _camera = GameManager.Instance.GetCamera(); return _camera; } set { _camera = value; } }
    [SerializeField] Transform _mainCameraParent;

    Transform _actualCameraPos;
    List<Transform> _cameraPositions = new List<Transform>();
    public IEnumerable<Transform> CameraPosGetter => _cameraPositions;

    [Header("-== Sensibility Properties ==-")]
    [SerializeField] private float _cameraSens = 500;
    private float _cameraSpeeed = 10;

    [Space(20)]
    [Header("-== FOV Properties ==-")]
    [SerializeField] float _walkingFOV;
    [SerializeField] float _runningFOV;
    private float _actualFOV;
    private bool _isLargeFOV = false;

    [Space(20)]
    [Header("-== Shake Properties ==-")]
    private Vector3 _initialCamPos;
    private bool _isShaking = false;
    private float _shakeDuration = 0f;
    [SerializeField] float _shakeMagnitude = 0.7f;
    [SerializeField] float _dampingSpeed = 1.0f;

    [Space(20)]
    [Header("-== Bobbing Properties ==-")]
    private bool _isBobbing = false;
    [SerializeField] float _bobbingSpeed = 0.18f;
    [SerializeField] float _bobbingAmount = 0.2f;
    private float _timer = 0.0f;

    [FormerlySerializedAs("_maxYRot")]
    [Space(20)]
    [Header("-== Camera Clamp Properties ==-")]
    [SerializeField] private float _maxXRot = 50;

    [FormerlySerializedAs("_minYRot")]
    [Space(20)]
    [Header("-== Camera Clamp Properties ==-")]
    [SerializeField] private float _minXRot = -50;

    private float _xRotation;
    private float _yRotation;

    [Space(20)]
    [Header("-== Interact Properties ==-")]
    [SerializeField] float _interactDistance;
    public CameraAim cameraAim { get; private set; }

    Action cameraMovement = delegate { };
    Action cameraEffects = delegate { };
    Action interactChecker = delegate { };

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }
    
    public override void OnAwake()
    {
        EventManager.Subscribe("CameraShake", ShakeState);
        EventManager.Subscribe("CameraBobbing", SetBobbing);
        EventManager.Subscribe("SetNewRotation", SetNewRotation);

        _model = GetComponent<Model>();

        Cursor.lockState = CursorLockMode.Locked;

        // Get Main Camera
        _cameraGetter = GameManager.Instance.GetCamera();
        GameManager.Instance.SetCameraParent(_mainCameraParent);
        _cameraGetter.transform.parent = null;

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

        _initialCamPos = _mainCameraParent.localPosition;
    }

    public override void OnStart()
    {
        EventManager.Subscribe("ChangeSens", ChangeSens);

        if (PlayerPrefs.HasKey("Sensibilidad"))
            _cameraSens = PlayerPrefs.GetFloat("Sensibilidad");
    }

    public override void OnLateStart()
    {
        cameraAim = new CameraAim(_cameraGetter, GameManager.Instance.Assistant, _interactDistance);
        interactChecker = cameraAim.CheckActualAim;
    }

    public override void OnUpdate()
    {
        interactChecker();
        cameraMovement();
        cameraEffects();
    }

    public override void OnLateUpdate()
    {
        _cameraGetter.transform.position = _mainCameraParent.transform.position;
        _cameraGetter.transform.rotation = transform.rotation * _actualCameraPos.localRotation;
    }

    #region Camera Move
    // Void for move the camera with an input
    public void MoveCamera(float xAxie, float yAxie)
    {
        var actualHorizontalRot = transform.rotation.eulerAngles.y;
        var actualVerticalRot = _actualCameraPos.rotation.eulerAngles.x;
        
        actualHorizontalRot += xAxie * _cameraSens * Time.deltaTime;
        actualVerticalRot += yAxie * -1 * _cameraSens * Time.deltaTime;

        if (actualVerticalRot is < 270 and > 210)
        {
            actualVerticalRot = 270;
        }

        if (actualVerticalRot is > 90 and < 190)
        {
            actualVerticalRot = 90;
        }

        // actualVerticalRot = Mathf.Clamp(actualVerticalRot, _minXRot, _maxXRot);

        //Debug.Log(actualVerticalRot);
        transform.rotation = Quaternion.Euler(new Vector3(0, actualHorizontalRot, 0));
        _actualCameraPos.localRotation = Quaternion.Euler(new Vector3(actualVerticalRot, 0, 0));
    }

    private void SetNewRotation(params object[] parameters)
    {
        var actualRot = (Vector3)parameters[0];
        
        transform.rotation = Quaternion.Euler(new Vector3(0, actualRot.y, 0));
        _actualCameraPos.localRotation = Quaternion.Euler(new Vector3(actualRot.x, 0, 0));
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

        if (Vector3.Distance(_mainCameraParent.transform.position, _actualCameraPos.position) < 0.2f)
        {
            _mainCameraParent.transform.position = _actualCameraPos.position;
            _initialCamPos = _cameraGetter.transform.localPosition;
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

        LeanTween.value(_cameraGetter.fieldOfView, _actualFOV, 0.15f).setOnUpdate((float value) =>
        {
            _cameraGetter.fieldOfView = value;
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
        _cameraGetter.transform.localPosition = _initialCamPos + UnityEngine.Random.insideUnitSphere * _shakeMagnitude;

        _shakeDuration -= Time.deltaTime * _dampingSpeed;

        if (_shakeDuration <= 0)
        {
            _shakeDuration = 0f;
            _cameraGetter.transform.localPosition = _initialCamPos;
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

            Vector3 pos = _cameraGetter.transform.localPosition;
            pos.y = _initialCamPos.y;
            _cameraGetter.transform.localPosition = pos;

            cameraEffects -= CameraBobbing;
        }
    }

    void CameraBobbing()
    {
        float waveslice = Mathf.Sin(_timer);
        _timer += _bobbingSpeed * Time.deltaTime;

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
            Vector3 pos = _cameraGetter.transform.localPosition;
            pos.y = _initialCamPos.y + translateChange;
            _cameraGetter.transform.localPosition = pos;
        }
        else
        {
            Vector3 pos = _cameraGetter.transform.localPosition;
            pos.y = _initialCamPos.y;
            _cameraGetter.transform.localPosition = pos;
        }
    }
}
