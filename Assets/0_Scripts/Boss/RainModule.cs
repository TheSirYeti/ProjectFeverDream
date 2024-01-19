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

    private float _expirationTimer = 10f;
    
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

    public void DoDrop()
    {
        ResetStatus();
        StartCoroutine(DoRainDrop());
    }

    public void ResetStatus()
    {
        _warningCircle.SetActive(true);
        _warningMat.SetColor("_Color", _startColor);
        transform.position = _startingPosition.position;
    }
    
    IEnumerator DoRainDrop()
    {
        float currentTimer = 0f;
        yield return new WaitForSeconds(_waitDropTime);

        float colorTimer = 0f;
        float finalColorTimer = 1f;

        while (colorTimer <= finalColorTimer)
        {
            Color lerpedColor = Color.Lerp(_startColor, _endColor, colorTimer);
            _warningMat.SetColor("_Color", lerpedColor);
            
            colorTimer += Time.deltaTime;
            yield return new WaitForSeconds(Time.deltaTime);
        }
        
        while (!Physics.Raycast(transform.position,
                   Vector3.down,
                   _raycastOffset,
                   LayerManager.LM_FLOOR) 
               && currentTimer < _expirationTimer)
        {
            currentTimer += Time.deltaTime;
            transform.position += _speed * Vector3.down * Time.deltaTime;
            
            yield return new WaitForSeconds(Time.deltaTime);
        }

        _impactParticles.Play();
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
    }
}
