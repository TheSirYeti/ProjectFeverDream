using System;
using System.Collections;
using System.Collections.Generic;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;
using Cursor = UnityEngine.Cursor;

public class MainMenuManager : MonoBehaviour
{
    [SerializeField] private Slider sfxSlider, musicSlider;
    [SerializeField] private TextMeshProUGUI sfxVolumeNumber, musicVolumeNumber;
    [SerializeField] private GameObject mainMenu, generalMenu, audioMenu, controllerMenu, graphicsMenu;
    
    private void Start()
    {
        Cursor.lockState = CursorLockMode.Confined;
        Cursor.visible = true;
    }

    private void Update()
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
        SoundManager.instance.volumeSFX = sfxSlider.value;
        PlayerPrefs.SetFloat("SFX_VOLUME_VALUE", sfxSlider.value);
        float value = sfxSlider.value * 100f;
        sfxVolumeNumber.text = Convert.ToInt32(value).ToString();
    }
    
    public void SetMusicVolume()
    {
        SoundManager.instance.volumeMusic = musicSlider.value;
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
        EventManager.ResetEventDictionary();
        SceneLoader.instance.SetupLoadScene(sceneID);
    }

    public void QuitGame()
    {
        Application.Quit();
    }
}
