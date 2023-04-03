using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.UI;

public class MenuController : MonoBehaviour
{
    public GameObject pauseMenu;

    GameObject _actualMenu;

    public GameObject landingmMenu;
    public GameObject options;

    public Slider sensSlider;
    public Slider musicSlider;
    public Slider soundSlider;

    bool _tempState = false;

    private void Start()
    {
        EventManager.Subscribe("PauseGame", MenuOn);
        EventManager.Subscribe("ResumeGame", MenuOff);

        EventManager.Subscribe("TempMenu", TempMenu);

        /*musicSlider.value = SoundManager.instance.volumeMusic;
        soundSlider.value = SoundManager.instance.volumeSFX;*/

        if (PlayerPrefs.HasKey("Sensibilidad"))
            sensSlider.value = PlayerPrefs.GetFloat("Sensibilidad");
        else
            sensSlider.value = 500;
    }

    void TempMenu(params object[] parameter)
    {
        if (!_tempState)
        {
            pauseMenu.SetActive(true);
            Cursor.lockState = CursorLockMode.Confined;
        }
        else
        {
            pauseMenu.SetActive(false);
            Cursor.lockState = CursorLockMode.Locked;
        }

        _tempState = !_tempState;
    }

    void MenuOn(params object[] parameter)
    {
        _actualMenu = landingmMenu;

        SoundManager.instance.PauseAllSounds();
        SoundManager.instance.PauseAllMusic();

        pauseMenu.SetActive(true);
    }

    void MenuOff(params object[] parameter)
    {
        _actualMenu.SetActive(false);
        _actualMenu = landingmMenu;
        _actualMenu.SetActive(true);

        SoundManager.instance.ResumeAllMusic();
        SoundManager.instance.ResumeAllSounds();

        pauseMenu.SetActive(false);
    }

    public void ReturnToMainMenu()
    {
        EventManager.Trigger("OnReturnToMainMenu");
    }

    public void BTN_ResumeGame()
    {
        EventManager.Trigger("ResumeGame");
    }

    public void BTN_Options()
    {
        _actualMenu.SetActive(false);
        _actualMenu = options;
        _actualMenu.SetActive(true);
    }

    public void BTN_Return()
    {
        _actualMenu.SetActive(false);
        _actualMenu = landingmMenu;
        _actualMenu.SetActive(true);
    }

    public void BTN_Quit()
    {
        EventManager.Trigger("OnLoadSceneRequest", 1);
    }

    public void ChangeSense(float sens)
    {
        EventManager.Trigger("ChangeSens", sens);
    }

    public void ChangeSoundsVolume(float soundsVol)
    {
        SoundManager.instance.ChangeVolumeSound(soundsVol);
    }

    public void ChangeMusicVolume(float musicVol)
    {
        SoundManager.instance.ChangeVolumeMusic(musicVol);
    }
}
