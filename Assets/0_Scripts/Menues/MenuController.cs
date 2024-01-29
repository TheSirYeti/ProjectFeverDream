using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;
using UnityEngine.PlayerLoop;
using UnityEngine.Serialization;

public class MenuController : GenericObject
{
    public GameObject pauseMenu;

    public GameObject primaryMenu;
    public GameObject secondaryMenu;

    public GameObject landingMenu;
    public GameObject options;
    public GameObject audioOptions;
    public GameObject controlsOptions;
    public GameObject graphicOptions;

    public GameObject[] selectedButtons;

    public Slider sensSlider;
    public Slider musicSlider;
    public Slider soundSlider;

    public TextMeshProUGUI sensText;
    public TextMeshProUGUI musicText;
    public TextMeshProUGUI sfxText;

    private bool _menuState = false;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnStart()
    {
        EventManager.Subscribe("MenuChanger", MenuChanger);

        musicSlider.value = SoundManager.instance.volumeMusic;
        soundSlider.value = SoundManager.instance.volumeSFX;

        if (PlayerPrefs.HasKey("Sensibilidad"))
            sensSlider.value = PlayerPrefs.GetFloat("Sensibilidad");
        else
            sensSlider.value = 500;
    }

    public override void OnUpdate()
    {
        if (Input.GetKeyDown(KeyCode.Escape))
        {
            EventManager.Trigger("MenuChanger");
        }
    }

    private void MenuChanger(params object[] parameter)
    {
        if (!_menuState)
        {
            pauseMenu.SetActive(true);
            Cursor.lockState = CursorLockMode.Confined;
            Cursor.visible = true;
            primaryMenu = landingMenu;
            SoundManager.instance.PauseAllMusic();
            SoundManager.instance.PauseAllSounds();
            SoundManager.instance.PauseAllVoiceLines();
            GameManager.Instance.PauseGame();
            CutsceneManager.instance.PauseTimeline();
        }
        else
        {
            foreach (var button in selectedButtons)
            {
                button.SetActive(false);
            }

            selectedButtons[0].SetActive(true);

            primaryMenu.SetActive(false);

            if (secondaryMenu) secondaryMenu.SetActive(false);
            
            primaryMenu = landingMenu;
            primaryMenu.SetActive(true);
            pauseMenu.SetActive(false);
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
            SoundManager.instance.ResumeAllMusic();
            SoundManager.instance.ResumeAllSounds();
            SoundManager.instance.ResumeAllVoiceLines();
            GameManager.Instance.ResumeGame();
            CutsceneManager.instance.ResumeTimeline();
        }

        _menuState = !_menuState;
    }

    public void BTN_ResumeGame()
    {
        EventManager.Trigger("MenuChanger");
    }

    public void BTN_Options()
    {
        primaryMenu.SetActive(false);
        primaryMenu = options;
        secondaryMenu = audioOptions;
        secondaryMenu.SetActive(true);
        primaryMenu.SetActive(true);
    }

    public void BTN_AudioOptions()
    {
        secondaryMenu?.SetActive(false);
        secondaryMenu = audioOptions;
        secondaryMenu.SetActive(true);
    }

    public void BTN_ControlOptions()
    {
        secondaryMenu?.SetActive(false);
        secondaryMenu = controlsOptions;
        secondaryMenu.SetActive(true);
    }

    public void BTN_GraphicOptions()
    {
        secondaryMenu?.SetActive(false);
        secondaryMenu = graphicOptions;
        secondaryMenu.SetActive(true);
    }

    public void BTN_Return()
    {
        foreach (var button in selectedButtons)
        {
            button.SetActive(false);
        }

        selectedButtons[0].SetActive(true);
        
        primaryMenu.SetActive(false);
        secondaryMenu?.SetActive(false);
        primaryMenu = landingMenu;
        primaryMenu.SetActive(true);
    }

    public void BTN_Quit()
    {
        EventManager.Trigger("OnResetTriggerLevel");
        PlayerPrefs.SetInt("LevelReplayCounter", 0);
        GameManager.Instance.ChangeScene(2);
    }

    public void ChangeSense(float sens)
    {
        EventManager.Trigger("ChangeSens", sens);
        sensText.text = ((sens / 1000) * 100).ToString("000");
    }

    public void ChangeSoundsVolume(float soundsVol)
    {
        SoundManager.instance.ChangeVolumeSound(soundsVol);
        sfxText.text = ((soundsVol / 1) * 100).ToString("000");
    }

    public void ChangeMusicVolume(float musicVol)
    {
        SoundManager.instance.ChangeVolumeMusic(musicVol);
        musicText.text = ((musicVol / 1) * 100).ToString("000");
    }
}