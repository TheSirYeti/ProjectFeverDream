using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.Serialization;
using UnityEngine.UI;

public class UIController : GenericObject
{
    [Header("Player UI")]
    [SerializeField] TextMeshProUGUI _healthUI;
    [SerializeField] Image _bulletsBar;
    [SerializeField] TextMeshProUGUI _primaryBulletUI;
    [SerializeField] TextMeshProUGUI _reserveBulletUI;
    [SerializeField] List<GameObject> _weaponsUI;
    [Space(20)] 
    [SerializeField] private List<GameObject> weaponRegion;
    [SerializeField] private List<GameObject> objectiveRegion;
    [SerializeField] private List<GameObject> controlsRegion;
    int _actualWeapon = 0;
    [Space(20)]
    [SerializeField] private Animator redScreenAnimator;

    [Header("Objetives")]
    [SerializeField] TextMeshProUGUI _titleObjetive;
    [SerializeField] TextMeshProUGUI _descriptionObjetive;
    [SerializeField] TextMeshProUGUI _progressObjective;
    [SerializeField] float timeToShow;

    [Header("Hitmarkers")] 
    [SerializeField] GameObject hitmarker; 
    [SerializeField] GameObject hitmarkerDead, hitmarkerWeak, hitmarkerHeadshot;
    
    [Space(10)] 
    [SerializeField] GameObject playerDamageMarker;
    [SerializeField] GameObject crosshair;

    [Header("Subtitles")] 
    [SerializeField] private TextMeshProUGUI subtitleText;

    [Header("Ping System")] 
    [SerializeField] private Image ping;
    [SerializeField] private Transform currentPingTarget;
    private bool isPingEnabled = false;    
    public Renderer buttonRenderer;
    private float fadeInValue = 0.5f;
    private float yBias = 35f;
    
    
    private Camera cam => GameManager.Instance.GetCamera();

    [Header("Interactable")]
    [SerializeField] private TextMeshProUGUI _interactuableUI;


    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }
    
    public override void OnStart()
    {
        SetUpEvents();
        
        ShowObjectiveUI(false);
        ChangeEquipedWeapontUI(-1);
    }

    public override void OnUpdate()
    {
        if (Input.GetKeyDown(KeyCode.Tab))
        {
            ShowObjectiveUI(true);
        }
        
        if (Input.GetKeyUp(KeyCode.Tab))
        {
            ShowObjectiveUI(false);
        }

        if (Input.GetKeyDown(KeyCode.LeftAlt))
        {
            ShowControlsUI(true);
        }
        
        if (Input.GetKeyUp(KeyCode.LeftAlt))
        {
            ShowControlsUI(false);
        }
        
        if (!isPingEnabled) return;
        
        if(currentPingTarget != null)
            SetPingPosition();
    }
 
    #region EVENTS

    void SetUpEvents()
    {
        EventManager.Subscribe("ChangeHealthUI", ChangeHealthUI);
        EventManager.Subscribe("ChangeBulletUI", ChangeBulletUI);
        EventManager.Subscribe("ChangeReserveBulletUI", ChangeReserveBulletUI);
        EventManager.Subscribe("ChangeEquipedWeapontUI", ChangeEquipedWeapontUI);
        EventManager.Subscribe("OnDamageableHit", TriggerHitmarker);
        EventManager.Subscribe("PlayerDamage", TriggerPlayerDamage);
        EventManager.Subscribe("OnADSEnabled", EnableADS);
        EventManager.Subscribe("OnADSDisabled", DisableADS);
        EventManager.Subscribe("ChangeObjetive", ChangesObjective);
        EventManager.Subscribe("ChangeObjectiveProgress", ChangeObjectiveProgress);
        EventManager.Subscribe("InteractUI", InteractUI);
        EventManager.Subscribe("OnSubtitleOn", DoSubtitle);
        EventManager.Subscribe("OnSubtitleOff", DisableSubtitle);
        EventManager.Subscribe("OnAssistantPing", DoPingStart);
        EventManager.Subscribe("OnPlayerTakeDamage", DoRedScreen);
    }

    #endregion

    #region PLAYER STATS
    
    void ChangeHealthUI(params object[] parameters)
    {
        _healthUI.text = parameters[0].ToString();
    }

    void ChangeBulletUI(params object[] parameters)
    {
        _primaryBulletUI.text = parameters[0].ToString();

        float a = (int)parameters[0];
        float b = (int)parameters[1];
        float value = a / b;

        _bulletsBar.fillAmount = value;
    }

    void ChangeReserveBulletUI(params object[] parameters)
    {
        _reserveBulletUI.text = parameters[0].ToString();
    }

    void ChangeEquipedWeapontUI(params object[] parameters)
    {
        foreach (var uiImage in _weaponsUI)
        {
            uiImage.SetActive(false);
        }

        if ((int)parameters[0] == -1)
        {
            foreach (var obj in weaponRegion)
            {
                obj.SetActive(false);
            }
            return;
        }
        
        foreach (var obj in weaponRegion)
        {
            obj.SetActive(true);
        }

        _actualWeapon = (int)parameters[0];
        _weaponsUI[_actualWeapon].SetActive(true);
    }

    void InteractUI(params object[] parameters)
    {
        if ((bool)parameters[0])
        {
            _interactuableUI.gameObject.SetActive(true);
            _interactuableUI.text = "Press F to: " + (string)parameters[1];
        }
        else
            _interactuableUI.gameObject.SetActive(false);
    }
    
    
    #endregion

    #region DAMAGE FEEDBACK
    
    void TriggerHitmarker(params object[] parameters)
    {
        int value = (int)parameters[0];

        switch (value)
        {
            case 0:
                StopCoroutine(DoHitmarker(hitmarker));
                StartCoroutine(DoHitmarker(hitmarker));
                break;
            case 1:
                StopCoroutine(DoHitmarker(hitmarkerHeadshot));
                StartCoroutine(DoHitmarker(hitmarkerHeadshot));
                break;
            case 2:
                StopCoroutine(DoHitmarker(hitmarkerWeak));
                StartCoroutine(DoHitmarker(hitmarkerWeak));
                break;
            case 3:
                StopCoroutine(DoHitmarker(hitmarkerDead));
                StartCoroutine(DoHitmarker(hitmarkerDead));
                break;
            default:
                StopCoroutine(DoHitmarker(hitmarker));
                StartCoroutine(DoHitmarker(hitmarker));
                break;
        }
    }

    void TriggerPlayerDamage(params object[] parameters)
    {
        playerDamageMarker.SetActive(true);
        playerDamageMarker.GetComponent<RectTransform>().rotation = Quaternion.Euler(new Vector3(0, 0, (float)parameters[0]) * -1);
        StartCoroutine(TurnOffDmgMarker());
    }
    
    IEnumerator DoHitmarker(GameObject hit)
    {
        hit.SetActive(true);
        yield return new WaitForSeconds(0.1f);
        hit.SetActive(false);
        yield return new WaitForEndOfFrame();
    }

    IEnumerator TurnOffDmgMarker()
    {
        yield return new WaitForSeconds(1f);
        playerDamageMarker.SetActive(false);
    }
    
    
    void DoRedScreen(object[] parameters)
    {
        redScreenAnimator.Play("TakeDamage");
    }
    
    #endregion

    #region ADS / CROSSHAIR

    void DisableADS(params object[] parameters)
    {
        crosshair.SetActive(true);
    }

    void EnableADS(params object[] parameters)
    {
        crosshair.SetActive(false);
    }

    #endregion

    #region OBJECTIVES

    void ChangesObjective(params object[] parameters)
    {
        _titleObjetive.text = (string)parameters[0];
        _descriptionObjetive.text = (string)parameters[1];
        _progressObjective.text = "0%";

        StartCoroutine(ShowObjectiveChange());
    }

    void ChangeObjectiveProgress(params object[] parameters)
    {
        _progressObjective.text = (string)parameters[0] + "%";
    }

    void ShowObjectiveUI(bool status)
    {
        foreach (var obj in objectiveRegion)
        {
            obj.SetActive(status);
        }
    }

    void ShowControlsUI(bool status)
    {
        foreach (var obj in controlsRegion)
        {
            obj.SetActive(status);
        }
    }

    IEnumerator ShowObjectiveChange()
    {
        ShowObjectiveUI(true);
        yield return new WaitForSeconds(timeToShow);
        ShowObjectiveUI(false);
        yield return null;
    }

    #endregion

    #region SUBTITLES

    void DoSubtitle(object[] parameters)
    {
        subtitleText.enabled = true;
        subtitleText.text = parameters[0] as string;
    }

    void DisableSubtitle(object[] parameters)
    {
        subtitleText.text = "";
        subtitleText.enabled = false;
    }

    #endregion

    #region PING

    void SetPingPosition()
    {
        var dir = currentPingTarget.position - cam.transform.position;
        if (Vector3.Angle(cam.transform.forward, dir) < 90)
        {
            ping.gameObject.SetActive(true);
            ping.transform.position = cam.WorldToScreenPoint(currentPingTarget.position) + new Vector3(0f, yBias, 0f);
        }
        else
        {
            ping.gameObject.SetActive(false);
        }
    }
    
    void DoPingStart(object[] parameters)
    {
        currentPingTarget = parameters[0] as Transform;

        isPingEnabled = true;
        LeanTween.value(0, 1, fadeInValue).setOnUpdate((float value) =>
        {
            ping.color = new Color(ping.color.r, ping.color.g, ping.color.b, value);
        });

        StartCoroutine(DoPingRuntime());
    }

    IEnumerator DoPingRuntime()
    {
        yield return new WaitForSeconds(2.5f);
        DoPingEnd(null);
        yield return new WaitForSeconds(fadeInValue);
        isPingEnabled = false;
    }
    
    void DoPingEnd(object[] parameters)
    {
        LeanTween.reset();
        
        LeanTween.value(1, 0, fadeInValue).setOnUpdate((float value) =>
        {
            ping.color = new Color(ping.color.r, ping.color.g, ping.color.b, value);
        });
    }

    #endregion
}
