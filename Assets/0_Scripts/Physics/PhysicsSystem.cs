using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;

public class PhysicsSystem
{
    #region Actual Impulse Forces
    // Impulse Lists
    private List<string> _impulseName = new List<string>();
    private List<Vector3> _impulseDir = new List<Vector3>();
    private List<float> _impulseForce = new List<float>();
    private List<float> _impulseSpeed = new List<float>();
    private Vector3 _impulseVector;
    #endregion

    #region Actual Constant Forces
    // Constant Lists
    private List<string> _constantName = new List<string>();
    private List<Vector3> _constantDir = new List<Vector3>();
    private List<float> _constantForce = new List<float>();
    private List<float> _constantDuration = new List<float>();
    private Vector3 _constantVector;
    #endregion

    #region Actual Acceleration Forces
    // Acceleration Lists
    private List<string> _accelerationName = new List<string>();
    private List<Vector3> _accelerationDir = new List<Vector3>();
    private List<float> _accelerationForce = new List<float>();
    private List<float> _accelerationDuration = new List<float>();
    private List<float> _accelerationSpeed = new List<float>();
    private Vector3 _accelerationVector;
    #endregion

    private Rigidbody _rb;

    public Action PhysicsFixedUpdate = delegate { };

    public PhysicsSystem(Rigidbody actualRB)
    {
        _rb = actualRB;
        PhysicsFixedUpdate += OnFixedUpdate;
    }

    void OnFixedUpdate()
    {
        Impulse();
        ConstantForce();
        Acceleration();

        _rb.velocity = _impulseVector + _constantVector + _accelerationVector;
    }

    public void RemoveAllPhysics()
    {
        _impulseName = new List<string>();
        _impulseDir = new List<Vector3>();
        _impulseForce = new List<float>();
        _impulseSpeed = new List<float>();
        _impulseVector = Vector3.zero;

        _constantName = new List<string>();
        _constantDir = new List<Vector3>();
        _constantForce = new List<float>();
        _constantDuration = new List<float>();
        _constantVector = Vector3.zero;

        _accelerationName = new List<string>();
        _accelerationDir = new List<Vector3>();
        _accelerationForce = new List<float>();
        _accelerationDuration = new List<float>();
        _accelerationSpeed = new List<float>();
        _accelerationVector = Vector3.zero;
    }

    #region Impulse Functions
    //Has Desacceleration
    public void ApplyImpulse(string forceName, Vector3 dir, float force, float desacceleration)
    {
        if (_impulseName.Contains(forceName))
        {
            int index = _impulseName.IndexOf(forceName);

            _impulseDir[index] = dir;
            _impulseForce[index] = force;
            _impulseSpeed[index] = desacceleration;
        }
        else
        {
            _impulseName.Add(forceName);
            _impulseDir.Add(dir);
            _impulseForce.Add(force);
            _impulseSpeed.Add(desacceleration);
        }
    }

    void Impulse()
    {
        if (!_impulseName.Any())
        {
            _impulseVector = Vector3.zero; 
            return;
        }

        _impulseVector = Vector3.zero;

        for (int i = 0; i < _impulseName.Count; i++)
        {
            _impulseVector += _impulseDir[i] * _impulseForce[i];
            _impulseForce[i] -= _impulseSpeed[i] * Time.deltaTime;

            if (_impulseForce[i] <= 0)
            {
                _impulseName.RemoveAt(i);
                _impulseDir.RemoveAt(i);
                _impulseForce.RemoveAt(i);
                _impulseSpeed.RemoveAt(i);
            }
        }
    }

    public void RemoveImpulse(string forceName)
    {
        if (!_impulseName.Contains(forceName)) return;

        int index = _impulseName.IndexOf(forceName);
        _impulseName.RemoveAt(index);
        _impulseDir.RemoveAt(index);
        _impulseForce.RemoveAt(index);
        _impulseSpeed.RemoveAt(index);
    }
    #endregion

    #region Constant Functions
    //Constant Force, 0 to 1 and 1 to 0
    public void ApplyConstantForce(string forceName, Vector3 dir, float force, float duration)
    {
        if (_constantName.Contains(forceName))
        {
            int index = _constantName.IndexOf(forceName);

            _constantDir[index] = dir;
            _constantForce[index] = force;
            _constantDuration[index] = duration;
        }
        else
        {
            _constantName.Add(forceName);
            _constantDir.Add(dir);
            _constantForce.Add(force);
            _constantDuration.Add(duration);
        }
    }

    void ConstantForce()
    {
        if (!_constantName.Any())
        {
            _constantVector = Vector3.zero;
            return;
        }

        _constantVector = Vector3.zero;

        for (int i = 0; i < _constantName.Count; i++)
        {
            _constantVector += _constantDir[i] * _constantForce[i];
            _constantDuration[i] -= Time.deltaTime;

            if (_constantDuration[i] <= 0)
            {
                _constantName.RemoveAt(i);
                _constantDir.RemoveAt(i);
                _constantForce.RemoveAt(i);
                _constantDuration.RemoveAt(i);
            }
        }
    }

    public void RemoveConstant(string forceName)
    {
        if (!_constantName.Contains(forceName)) return;

        int index = _constantName.IndexOf(forceName);

        _constantName.RemoveAt(index);
        _constantDir.RemoveAt(index);
        _constantForce.RemoveAt(index);
        _constantDuration.RemoveAt(index);
    }
    #endregion

    #region Acceleration Functions
    // Has Acceleration
    public void ApplyAcceleration(string forceName, Vector3 dir, float speed, float duration)
    {
        if (_accelerationName.Contains(forceName))
        {
            int index = _accelerationName.IndexOf(forceName);

            _accelerationDir[index] = dir;
            _accelerationForce[index] = 0;
            _accelerationSpeed[index] = speed;
            _accelerationDuration[index] = duration;
        }
        else
        {
            _accelerationName.Add(forceName);
            _accelerationDir.Add(dir);
            _accelerationForce.Add(0);
            _accelerationSpeed.Add(speed);
            _accelerationDuration.Add(duration);
        }
    }

    void Acceleration()
    {
        if (!_accelerationName.Any())
        {
            _accelerationVector = Vector3.zero;
            return;
        }

        _accelerationVector = Vector3.zero;

        for (int i = 0; i < _accelerationName.Count; i++)
        {
            _accelerationVector += _accelerationDir[i] * _accelerationForce[i];
            _accelerationForce[i] += _accelerationSpeed[i] * Time.deltaTime;
            _accelerationDuration[i] -= Time.deltaTime;

            if (_accelerationDuration[i] <= 0)
            {
                _accelerationName.RemoveAt(i);
                _accelerationDir.RemoveAt(i);
                _accelerationForce.RemoveAt(i);
                _accelerationSpeed.RemoveAt(i);
                _accelerationDuration.RemoveAt(i);
            }
        }
    }

    public void RemoveAcceleration(string forceName)
    {
        if (!_accelerationName.Contains(forceName)) return;

        int index = _accelerationName.IndexOf(forceName);

        _accelerationName.RemoveAt(index);
        _accelerationDir.RemoveAt(index);
        _accelerationForce.RemoveAt(index);
        _accelerationSpeed.RemoveAt(index);
        _accelerationDuration.RemoveAt(index);
    }

    public bool HasGravity()
    {
        if (_accelerationName.Contains("gravity"))
            return true;

        return false;
    }
    #endregion
}
