using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;

public class MonitorInfo : GenericObject
{
    [SerializeField] private GameObject _standbyInfo, _duringInfo, _doneInfo;
    [SerializeField] private TextMeshPro _clock;

    private float _currentTime = 0f;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnUpdate()
    {
        if(_duringInfo.activeSelf || _doneInfo.activeSelf)
            DoCountdown();
    }

    public void SetClockTimer(float time)
    {
        _standbyInfo.SetActive(false);
        _duringInfo.SetActive(true);

        _currentTime = time;
    }

    public void DoCountdown()
    {
        CheckDuringStatus();

        float mm = Mathf.FloorToInt(_currentTime / 60);
        float ss = Mathf.FloorToInt(_currentTime % 60);

        _clock.text = string.Format("{0:00}:{1:00}", mm, ss);
    }

    public void CheckDuringStatus()
    {
        if (_currentTime > 0)
            _currentTime -= Time.deltaTime;
        else
        {
            _currentTime = 0;
            if (_duringInfo.activeSelf)
            {
                SetAsDone();
                return;
            }

            if (_doneInfo.activeSelf)
            {
                _doneInfo.SetActive(false);
                _standbyInfo.SetActive(true);
            }
        }
    }

    public void SetAsDone()
    {
        _duringInfo.SetActive(false);
        _doneInfo.SetActive(true);
        _currentTime = 1.5f;
    }
}
