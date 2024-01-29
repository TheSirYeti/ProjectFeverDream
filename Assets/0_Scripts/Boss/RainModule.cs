using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class RainModule : GenericObject
{
    [SerializeField] private int _totalDamage;
    [Space(10)]
    [SerializeField] private float _speed;
    [SerializeField] private Transform _startingPosition;
    [SerializeField] private GameObject _warningCircle;
    [SerializeField] private ParticleSystem _impactParticles;
    [Space(10)] 
    [SerializeField] private float _waitDropTime;
    private Renderer _warningRenderer;
    private Material _warningMat;
    [SerializeField] private Color _startColor, _endColor;
    
    [SerializeField] private float _raycastOffset;

    float colorTimer = 0f;
    private float _expirationTimer = 10f;
    private bool hasDropped = false;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
        
        _startingPosition.position = transform.position;
        _startingPosition.parent = null;
        
        _warningCircle.transform.parent = null;
        _warningRenderer = _warningCircle.GetComponent<Renderer>();
        _warningMat = _warningRenderer.material;
       
        _warningCircle.SetActive(false);
        gameObject.SetActive(false);
    }

    public override void OnUpdate()
    {
        if (gameObject.activeSelf)
        {
            Color lerpedColor = Color.Lerp(_startColor, _endColor, colorTimer / 2f);
            _warningMat.SetColor("_Color", lerpedColor);
            
            colorTimer += Time.deltaTime;

            if (!hasDropped)
            {
                transform.position += _speed * Vector3.down * Time.deltaTime;
            }

            if (Physics.Raycast(transform.position,
                    Vector3.down,
                    _raycastOffset,
                    LayerManager.LM_FLOOR)
                && currentTimer < _expirationTimer)
            {
                if (!hasDropped)
                {
                    StartCoroutine(StopRainDrop());
                }
                hasDropped = true;
            }
        }
    }

    public void DoDrop()
    {
        ResetStatus();
    }

    public void ResetStatus()
    {
        _warningCircle.SetActive(true);
        _warningMat.SetColor("_Color", _startColor);
        colorTimer = 0f;
        currentTimer = 0f;
        hasDropped = false;
        transform.position = _startingPosition.position;
    }

    private float currentTimer = 0f;
    void DoRainDrop()
    {
        if (!Physics.Raycast(transform.position,
                Vector3.down,
                _raycastOffset,
                LayerManager.LM_FLOOR)
            && currentTimer < _expirationTimer)
        {
            currentTimer += Time.deltaTime;
            transform.position += _speed * Vector3.down * Time.deltaTime;
        }
    }
    
    IEnumerator StopRainDrop()
    {
        _impactParticles.Play();
        if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
        yield return new WaitForSeconds(1.5f);
        _warningCircle.SetActive(false);
        gameObject.SetActive(false);
        yield return null;
    }
    
    private void OnTriggerEnter(Collider other)
    {
        IPlayerLife playerLife = other.GetComponentInParent<IPlayerLife>();

        if (playerLife != null)
        {
            playerLife.GetDamage(_totalDamage);
        }

        if (other.gameObject.layer == LayerManager.LM_FLOOR)
        {
            StartCoroutine(StopRainDrop());
            hasDropped = true;
        }
    }
}
