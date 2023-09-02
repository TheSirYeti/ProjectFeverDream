using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;

public class FastVent : GenericObject
{
    [SerializeField] private Transform[] _enterPoint;
    [SerializeField] private Transform[] _wayPoints;

    [SerializeField] private float _detectionRadius;
    [SerializeField] private float _speed;
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
            EventManager.Trigger("ChangeMovementInputs", false);
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
        _playerTransform.position += dir.normalized * (_speed * Time.deltaTime);

        if (dir.magnitude < 0.3f)
        {
            _actualWayPoint += _actualDir;

            if (_actualWayPoint < 0 || _actualWayPoint >= _wayPoints.Length)
            {
                EventManager.Trigger("ChangeMovementInputs", true);
                EventManager.Trigger("ChangePhysicsState", true);
                ActualUpdate = delegate {  };
                StartCoroutine(WaitForReset());
            }
        }
    }

    private IEnumerator WaitForReset()
    {
        yield return new WaitForSeconds(_cdPerUse);
        ActualUpdate = CheckForPlayer;
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

