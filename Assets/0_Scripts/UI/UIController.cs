using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.UI;

public class UIController : MonoBehaviour
{
    [Header("Player UI")]
    [SerializeField] TextMeshProUGUI _healthUI;
    [SerializeField] Image _bulletsBar;
    [SerializeField] TextMeshProUGUI _primaryBulletUI;
    [SerializeField] TextMeshProUGUI _reserveBulletUI;
    [SerializeField] List<GameObject> _weaponsUI;
    int _actualWeapon = 0;


    [Header("ObjetiveText")]
    [SerializeField] TextMeshProUGUI _titleObjetive;
    [SerializeField] TextMeshProUGUI _descriptionObjetive;
    [SerializeField] TextMeshProUGUI _progressObjective;

    [Header("GameObjects")]
    [SerializeField] GameObject hitmarker, hitmarkerDead, hitmarkerWeak, hitmarkerHeadshot;
    [SerializeField] GameObject playerDamageMarker;
    [SerializeField] GameObject crosshair;

    [Header("Subtitles")] 
    [SerializeField] private TextMeshProUGUI subtitleText;

    [SerializeField] Color _baseTextColor;

    [SerializeField] TextMeshProUGUI fpsCounter;

    void Start()
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
        EventManager.Subscribe("OnSubtitleOn", DoSubtitle);
        EventManager.Subscribe("OnSubtitleOff", DisableSubtitle);
    }

    private void Update()
    {
        //int current = (int)(1f / Time.unscaledDeltaTime);
        //fpsCounter.text = current.ToString();
    }

    void ChangeHealthUI(params object[] parameters)
    {
        _healthUI.text = parameters[0].ToString();
    }

    void ChangeBulletUI(params object[] parameters)
    {
        Debug.Log("A" + parameters[0]);
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

        if (!_weaponsUI[(int)parameters[0]]) return;

        _actualWeapon = (int)parameters[0];
        _weaponsUI[_actualWeapon].SetActive(true);
    }

    //void ChangeCoinsUI(params object[] parameters)
    //{
    //    _coinsUI.text = parameters[0].ToString();
    //}

    //void ShopUI(params object[] parameters)
    //{
    //    if ((bool)parameters[0])
    //    {
    //        _interactuableUI.gameObject.SetActive(true);
    //        _interactuableUI.text = "Weapon Cost = " + parameters[1].ToString() + ". Bullet Cost = " + parameters[2].ToString();
    //    }
    //    else
    //        _interactuableUI.gameObject.SetActive(false);
    //}

    //void DoorUI(params object[] parameters)
    //{
    //    if ((bool)parameters[0])
    //    {
    //        _interactuableUI.gameObject.SetActive(true);
    //        _interactuableUI.text = "Door Cost = " + parameters[1].ToString();
    //    }
    //    else
    //        _interactuableUI.gameObject.SetActive(false);
    //}

    //void InteractUI(params object[] parameters)
    //{
    //    if ((bool)parameters[0])
    //    {
    //        _interactuableUI.gameObject.SetActive(true);
    //        _interactuableUI.text = (string)parameters[1];
    //    }
    //    else
    //        _interactuableUI.gameObject.SetActive(false);
    //}

    //void BuyItem(params object[] parameters)
    //{
    //    CancelInvoke();
    //    _interactuableUI.color = Color.yellow;
    //    Invoke("BackToBaseColor", 0.5f);
    //}

    //void RefuseItem(params object[] parameters)
    //{
    //    CancelInvoke();
    //    _interactuableUI.color = Color.red;
    //    Invoke("BackToBaseColor", 0.5f);
    //}

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

    void DisableADS(params object[] parameters)
    {
        crosshair.SetActive(true);
    }

    void EnableADS(params object[] parameters)
    {
        crosshair.SetActive(false);
    }

    //void BackToBaseColor()
    //{
    //    _interactuableUI.color = _baseTextColor;
    //}

    //void OnPhaseEnd(params object[] parameters)
    //{
    //    _enemiesCounterUI.gameObject.SetActive(false);
    //    _waveClearUI.gameObject.SetActive(true);
    //    _waveTimerUI.gameObject.SetActive(true);
    //}

    //void ChangeTimer(params object[] parameters)
    //{
    //    _waveTimerUI.text = "Next phase starts in " + parameters[0].ToString() + " seconds";
    //}

    //void OnPhaseStart(params object[] parameters)
    //{
    //    _waveClearUI.gameObject.SetActive(false);
    //    _waveTimerUI.gameObject.SetActive(false);
    //    _enemiesCounterUI.gameObject.SetActive(true);
    //}

    //void ChangeActualObjectiveState(params object[] parameters)
    //{
    //    //SoundManager.instance.PlaySound(SoundID.TASK_DONE);
    //    _stateObjetive.color = Color.green;
    //    _stateObjetive.text = "Status - Finished.";
    //}

    void ChangesObjective(params object[] parameters)
    {
        _titleObjetive.text = (string)parameters[0];
        _descriptionObjetive.text = (string)parameters[1];
        //_stateObjetive.color = Color.white;
        //_stateObjetive.text = "Status - In Progress.";
        _progressObjective.text = "0%";
    }

    void ChangeObjectiveProgress(params object[] parameters)
    {
        _progressObjective.text = (string)parameters[0] + "%";
    }

    //void HookUI(params object[] parameters)
    //{
    //    /*if ((bool)parameters[0])
    //        _hookUI.SetActive(true);
    //    else
    //        _hookUI.SetActive(false);*/
    //        StopCoroutine(DoHookUI());
    //    StartCoroutine(DoHookUI());
    //}

    //IEnumerator DoHookUI()
    //{
    //    _hookUI.SetActive(true);
    //    yield return new WaitForSeconds(1f);
    //    _hookUI.SetActive(false);
    //    yield return null;
    //}
    

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

    //IEnumerator DoRoundCounterCycle(int currentRound)
    //{
    //    _waveCounterAnimator.SetTrigger("ChangeRound");
    //    yield return new WaitForSeconds(0.3f);
    //    _waveCounterUI.text = currentRound.ToString();
    //    yield return new WaitForSeconds(0.001f);
    //}

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
}
