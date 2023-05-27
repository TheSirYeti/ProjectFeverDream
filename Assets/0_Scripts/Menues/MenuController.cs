using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class MenuController : GenericObject
{
    public GameObject pauseMenu;

    public GameObject _primaryMenu;
    public GameObject _secondaryMenu;

    public GameObject landingMenu;
    public GameObject options;
    public GameObject audioOptions;
    public GameObject controlsOptions;
    public GameObject graphicOptions;

    public List<GameObject> selectedButtons;

    public Slider sensSlider;
    public Slider musicSlider;
    public Slider soundSlider;

    public TextMeshProUGUI sensText;
    public TextMeshProUGUI musicText;
    public TextMeshProUGUI sfxText;

    bool _tempState = false;

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

    void MenuChanger(params object[] parameter)
    {
        if (!_tempState)
        {
            pauseMenu.SetActive(true);
            Cursor.lockState = CursorLockMode.Confined;
            Cursor.visible = true;
            _primaryMenu = landingMenu;
            SoundManager.instance.PauseAllMusic();
            SoundManager.instance.PauseAllSounds();
            SoundManager.instance.PauseAllVoiceLines();
            //TODO: Change Later
            Time.timeScale = 0;
        }
        else
        {
            _primaryMenu.SetActive(false);
            _secondaryMenu?.SetActive(false);
            _primaryMenu = landingMenu;
            _primaryMenu.SetActive(true);
            pauseMenu.SetActive(false);
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
            SoundManager.instance.ResumeAllMusic();
            SoundManager.instance.ResumeAllSounds();
            SoundManager.instance.ResumeAllVoiceLines();
            //TODO: Change Later
            Time.timeScale = 1;
        }

        _tempState = !_tempState;
    }

    public void ReturnToMainMenu()
    {
        //EventManager.Trigger("OnReturnToMainMenu");
        SceneLoader.instance.SetupLoadScene(3);
    }

    public void BTN_ResumeGame()
    {
        EventManager.Trigger("MenuChanger");
    }

    public void BTN_Options()
    {
        _primaryMenu.SetActive(false);
        _primaryMenu = options;
        _secondaryMenu = audioOptions;
        _secondaryMenu.SetActive(true);
        _primaryMenu.SetActive(true);
    }

    public void BTN_AudioOptions()
    {
        _secondaryMenu?.SetActive(false);
        _secondaryMenu = audioOptions;
        _secondaryMenu.SetActive(true);
    }

    public void BTN_ControlOptions()
    {
        _secondaryMenu?.SetActive(false);
        _secondaryMenu = controlsOptions;
        _secondaryMenu.SetActive(true);
    }

    public void BTN_GraphicOptions()
    {
        _secondaryMenu?.SetActive(false);
        _secondaryMenu = graphicOptions;
        _secondaryMenu.SetActive(true);
    }

    public void BTN_Return()
    {
        _primaryMenu.SetActive(false);
        _secondaryMenu?.SetActive(false);
        _primaryMenu = landingMenu;
        _primaryMenu.SetActive(true);
    }

    public void BTN_Quit()
    {
        SceneLoader.instance.SetupLoadScene(3);
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
