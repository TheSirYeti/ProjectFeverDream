using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;
using Random = UnityEngine.Random;

public class FastVent : GenericObject
{
    private bool isEnabled = false;
    [SerializeField] private Transform[] _enterPoint;
    [SerializeField] private Transform[] _wayPoints;
    [SerializeField] private GameObject _playerLight;
    
    [SerializeField] private float _detectionRadius;
    [SerializeField] private float _speed;
    [SerializeField] private float _rotationSpeed;
    [SerializeField] private float _cdPerUse;

    private Action ActualUpdate = delegate { };

    private Transform _playerTransform;
    private int _actualWayPoint;
    private int _actualDir = 1;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnAwake()
    {
        ActualUpdate = CheckForPlayer;
    }

    public override void OnUpdate()
    {
        if(isEnabled)
            ActualUpdate();
    }

    private void CheckForPlayer()
    {
        for (var i = 0; i < _enterPoint.Length; i++)
        {
            var playerCol = Physics.OverlapSphere(_enterPoint[i].position, _detectionRadius, LayerManager.LM_PLAYER);

            if (playerCol.Length == 0) continue;

            _playerTransform = playerCol[0].transform.parent.parent;
            ActualUpdate = MovePlayer;
            _playerLight.SetActive(true);
            EventManager.Trigger("ChangeMovementState", false, true);
            EventManager.Trigger("ChangePhysicsState", false);

            if (i == 0)
            {
                _actualWayPoint = 0;
                _actualDir = 1;
            }
            else
            {
                _actualWayPoint = _wayPoints.Length - 1;
                _actualDir = -1;
            }

            break;
        }
    }

    private void MovePlayer()
    {
        var dir = _wayPoints[_actualWayPoint].position - _playerTransform.position;
        
        var targetRotation = Quaternion.LookRotation(dir);
        _playerTransform.rotation = Quaternion.Lerp(_playerTransform.rotation, targetRotation, _rotationSpeed * Time.deltaTime);
        _playerTransform.position += dir.normalized * (_speed * Time.deltaTime);
        _playerLight.transform.position = _playerTransform.position;

        if (dir.magnitude < 0.3f)
        {
            _actualWayPoint += _actualDir;
            if (SoundManager.instance != null)
            {
                int randSfx = Random.Range(1, 4);
                SoundManager.instance.PlaySoundByID("VENT_HIT_" + randSfx);
            }

            if (_actualWayPoint < 0 || _actualWayPoint >= _wayPoints.Length)
            {
                EventManager.Trigger("ChangeMovementState", true, false);
                EventManager.Trigger("ChangePhysicsState", true);
                ActualUpdate = delegate { };
                StartCoroutine(WaitForReset());
            }
        }
    }

    private IEnumerator WaitForReset()
    {
        yield return new WaitForSeconds(_cdPerUse);
        ActualUpdate = CheckForPlayer;
    }

    public void EnableVent()
    {
        isEnabled = true;
    }

    private void OnDrawGizmos()
    {
        Gizmos.color = Color.red;

        foreach (var enterPoint in _enterPoint)
        {
            Gizmos.DrawWireSphere(enterPoint.position, _detectionRadius);
        }

        if (!_wayPoints.Any()) return;

        Gizmos.color = Color.blue;
        foreach (var wayPoint in _wayPoints)
        {
            Gizmos.DrawWireSphere(wayPoint.position, 0.5f);
        }
    }
}