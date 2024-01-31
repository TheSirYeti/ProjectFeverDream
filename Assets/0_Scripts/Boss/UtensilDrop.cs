using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class UtensilDrop : GenericObject
{
    [SerializeField] private ParticleSystem _impactParticles;
    [SerializeField] private GameObject _warningCircle;
    private MeshRenderer _warningRenderer;
    private Material _warningMat;
    [SerializeField] private Color _startColor, _endColor;
    [Space(10)]
    [SerializeField] private Transform _centerOfImpact;
    [SerializeField] private float _raycastOffset;
    [SerializeField] private float _downwardSpeed;
    [Space(10)] 
    [SerializeField] private int _totalDamage;
    [Space(10)]
    [SerializeField] private float _timeToDie;

    private bool hasCollided = false;
    private float currentTimer = 0f;
    private float expirationTimer = 10f;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnStart()
    {
        Debug.Log("SOY UNA SARTEN!");
        _warningRenderer = _warningCircle.GetComponent<MeshRenderer>();
        _warningMat = _warningRenderer.material;
        StartCoroutine(DropUtensil());
    }

    IEnumerator DropUtensil()
    {
        Physics.Raycast(_centerOfImpact.position, Vector3.down, out RaycastHit hit, Mathf.Infinity, LayerManager.LM_FLOOR);

        _warningCircle.transform.position = hit.point + new Vector3(0, 0.1f, 0);
        _warningCircle.transform.parent = null;
        
        while (!Physics.Raycast(_centerOfImpact.position,
                   Vector3.down,
                   _raycastOffset,
                   LayerManager.LM_FLOOR) 
               && currentTimer < expirationTimer)
        {
            if (UpdateManager.instance.IsPaused()) yield return new WaitUntil(() => !UpdateManager.instance.IsPaused());
            Color lerpedColor = Color.Lerp(_startColor, _endColor, currentTimer / 2f);
            _warningMat.SetColor("_Color", lerpedColor);
            
            currentTimer += Time.deltaTime;
            transform.position += _downwardSpeed * Vector3.down * Time.deltaTime;
            
            yield return null;
        }

        hasCollided = true;
        if (_impactParticles != null)
        {
            _impactParticles.Play();
        }

        yield return new WaitForSeconds(_timeToDie);
        
        Destroy(_warningCircle);
        Destroy(gameObject);
    }

    private void OnTriggerEnter(Collider other)
    {
        IPlayerLife playerLife = other.GetComponentInParent<IPlayerLife>();

        if (playerLife != null)
        {
            playerLife.GetDamage(_totalDamage);
        }
    }

    private void OnDrawGizmos()
    {
        Gizmos.DrawLine(_centerOfImpact.position, _centerOfImpact.position + new Vector3(0, _raycastOffset, 0));
    }
}
