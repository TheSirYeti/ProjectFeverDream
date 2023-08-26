using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;

public abstract class UIFeedbackAbstract : MonoBehaviour
{
    [Header("Variables")]
    [Range(0f, 10f)]
    [SerializeField] protected float _speed;
    protected float _value;
    public bool _enabled = false;

    [Range(0f, 1f)]
    protected Vector2 _scaleInitial = new Vector2(1, 1);
    protected Vector2 _scaleFinal = new Vector2(1.08f, 1.08f);
}
