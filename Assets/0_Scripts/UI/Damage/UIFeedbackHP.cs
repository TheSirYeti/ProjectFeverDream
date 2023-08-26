using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using TMPro;
using UnityEngine.UI;

public class UIFeedbackHP : UIFeedbackAbstract
{
    [SerializeField] protected Color _colorOne;
    [SerializeField] protected Color _colorTwo;

    [Header("Transform & Text")]

    public RectTransform transformObject;
    public TMP_Text _text;
    public Image _image;

    public bool _imageActive = false;

    void Start()
    {
        _colorOne = _text.color;
    }

    void Update()
    {
        LowHPChangeColor(_enabled);
        ScaleText(_enabled);
    }

    void LowHPChangeColor(bool on)
    {
        if (_enabled)
        {
            var lerp = Mathf.PingPong(_value += (Time.deltaTime * _speed),1);
            _text.color = Color.Lerp(_colorOne, _colorTwo, lerp);

            if(_imageActive && _image !=null)
                _image.color = Color.Lerp(Color.white, _colorTwo, lerp);

            if (_value > 1)
                _value = -_value;
        }
        else
        {
            _text.color = _colorOne;
            if (_imageActive && _image !=null)
                _image.color = _colorOne;
        }

    }

    void ScaleText(bool on)
    {
        if (_enabled)
            transformObject.transform.localScale = Vector2.Lerp(_scaleInitial, _scaleFinal, Mathf.PingPong(_value += (Time.deltaTime * _speed), 1));
        else
            transformObject.transform.localScale = _scaleInitial;
    }
}
