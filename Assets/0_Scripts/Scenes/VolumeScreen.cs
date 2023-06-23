using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class VolumeScreen : GenericObject
{
    [SerializeField] private Slider sfxSlider, musicSlider;
    [SerializeField] private int nextScene;
    
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }
    
    public override void OnStart()
    {
        Cursor.visible = true;
        Cursor.lockState = CursorLockMode.Confined;
        
        
        if (PlayerPrefs.HasKey("SFX_VOLUME_VALUE"))
        {
            sfxSlider.value = PlayerPrefs.GetFloat("SFX_VOLUME_VALUE");
            musicSlider.value = PlayerPrefs.GetFloat("MUSIC_VOLUME_VALUE");
        }
        else
        {
            sfxSlider.value = 0.5f;
            musicSlider.value = 0.5f;
            
            PlayerPrefs.SetFloat("SFX_VOLUME_VALUE", 0.5f);
            PlayerPrefs.SetFloat("MUSIC_VOLUME_VALUE", 0.5f);
        }
    }

    public void SetSFXVolume()
    {
        SoundManager.instance.ChangeVolumeSound(sfxSlider.value);
        PlayerPrefs.SetFloat("SFX_VOLUME_VALUE", sfxSlider.value);
    }
    
    public void SetMusicVolume()
    {
        SoundManager.instance.ChangeVolumeMusic(musicSlider.value);
        PlayerPrefs.SetFloat("MUSIC_VOLUME_VALUE", musicSlider.value);
    }
    
    public void TestSFX()
    {
        SoundManager.instance.PlaySound(SoundID.TEST_TOASTER_DING);
    }

    public void TestMusic()
    {
        SoundManager.instance.PlayMusic(MusicID.TEST_JIGGY);
    }

    public void SetupFinished()
    {
        SoundManager.instance.StopAllMusic();
        SoundManager.instance.StopAllSounds();
        GameManager.Instance.NextScene();
    }
}
