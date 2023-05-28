using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using Cursor = UnityEngine.Cursor;

public class MainMenuManager : GenericObject
{
    [SerializeField] private Slider sfxSlider, musicSlider;
    [SerializeField] private TextMeshProUGUI sfxVolumeNumber, musicVolumeNumber;
    [SerializeField] private GameObject mainMenu, generalMenu, audioMenu, controllerMenu, graphicsMenu;
    
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }
    
    public override void OnStart()
    {
        SoundManager.instance.StopAllMusic();
        SoundManager.instance.StopAllSounds();
        SoundManager.instance.PlayMusic(MusicID.MAINMENU, true);
        Cursor.lockState = CursorLockMode.Confined;
        Cursor.visible = true;
    }

    public override void OnUpdate()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            ResetMenu();
        }
    }

    public void ResetMenu()
    {
        mainMenu.SetActive(true);
        generalMenu.SetActive(false);
        audioMenu.SetActive(false);
        controllerMenu.SetActive(false);
        graphicsMenu.SetActive(false);
    }

    public void SetSFXVolume()
    {
        SoundManager.instance.ChangeVolumeSound(sfxSlider.value);
        PlayerPrefs.SetFloat("SFX_VOLUME_VALUE", sfxSlider.value);
        float value = sfxSlider.value * 100f;
        sfxVolumeNumber.text = Convert.ToInt32(value).ToString();
    }
    
    public void SetMusicVolume()
    {
        SoundManager.instance.ChangeVolumeMusic(musicSlider.value);
        PlayerPrefs.SetFloat("MUSIC_VOLUME_VALUE", musicSlider.value);
        float value = musicSlider.value * 100f;
        musicVolumeNumber.text = Convert.ToInt32(value).ToString();
    }

    public void GetNewValues()
    {
        if (PlayerPrefs.HasKey("SFX_VOLUME_VALUE"))
        {
            musicSlider.value = SoundManager.instance.volumeMusic;
            sfxSlider.value = SoundManager.instance.volumeSFX;
            musicVolumeNumber.text = Convert.ToInt32(musicSlider.value * 100f).ToString();
            sfxVolumeNumber.text = Convert.ToInt32(sfxSlider.value * 100f).ToString();
        }
    }
    
    public void LoadScene(int sceneID)
    {
        GameManager.Instance.ChangeScene(sceneID);
    }

    public void QuitGame()
    {
        Application.Quit();
    }
}
