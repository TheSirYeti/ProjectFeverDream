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
    [SerializeField] private Slider sfxSlider, musicSlider, sensSlider;
    [SerializeField] private TextMeshProUGUI sfxVolumeNumber, musicVolumeNumber, sensText;
    [SerializeField] private GameObject mainMenu, generalMenu, audioMenu, controllerMenu, graphicsMenu;

    [SerializeField] private GameObject[] _selectedButton;
    
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }
    
    public override void OnStart()
    {
        PlayerPrefs.SetFloat("CurrentCheckpoint", 0);
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
        foreach (var button in _selectedButton)
        {
            button.SetActive(false);
        }
        _selectedButton[0].SetActive(true);
        
        mainMenu.SetActive(true);
        generalMenu.SetActive(false);
        audioMenu.SetActive(false);
        controllerMenu.SetActive(false);
        graphicsMenu.SetActive(false);
    }

    public void SetSFXVolume(float volume)
    {
        SoundManager.instance.ChangeVolumeSound(volume);
        PlayerPrefs.SetFloat("SFX_VOLUME_VALUE", volume);
        float value = volume * 100f;
        sfxVolumeNumber.text = Convert.ToInt32(value).ToString();
    }
    
    public void SetMusicVolume(float volume)
    {
        SoundManager.instance.ChangeVolumeMusic(volume);
        PlayerPrefs.SetFloat("MUSIC_VOLUME_VALUE", volume);
        float value = volume * 100f;
        musicVolumeNumber.text = Convert.ToInt32(value).ToString();
    }
    
    public void ChangeSense(float sens)
    {
        PlayerPrefs.SetFloat("Sensibilidad", sens);
        sensText.text = ((sens / 1000) * 100).ToString("000");
    }

    public void GetNewValues()
    {
        if (PlayerPrefs.HasKey("SFX_VOLUME_VALUE"))
        {
            sfxSlider.value = PlayerPrefs.GetFloat("SFX_VOLUME_VALUE");;
            sfxVolumeNumber.text = Convert.ToInt32(sfxSlider.value * 100f).ToString();
        }

        if (PlayerPrefs.HasKey("MUSIC_VOLUME_VALUE"))
        {
            musicSlider.value = PlayerPrefs.GetFloat("MUSIC_VOLUME_VALUE");
            musicVolumeNumber.text = Convert.ToInt32(musicSlider.value * 100f).ToString();
        }
        
        if (PlayerPrefs.HasKey("Sensibilidad"))
        {
            sensSlider.value = PlayerPrefs.GetFloat("Sensibilidad");;
            sensText.text = Convert.ToInt32(sensSlider.value * 100f).ToString();
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
