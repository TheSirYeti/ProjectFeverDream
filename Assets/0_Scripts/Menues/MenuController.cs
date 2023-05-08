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
        EventManager.Subscribe("MenuChanger", MenuChanger);

        /*musicSlider.value = SoundManager.instance.volumeMusic;
        soundSlider.value = SoundManager.instance.volumeSFX;*/

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

            //TODO: Change Later
            Time.timeScale = 0;
        }
        else
        {
            pauseMenu.SetActive(false);
            Cursor.lockState = CursorLockMode.Locked;
            Cursor.visible = false;
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
        SceneLoader.instance.SetupLoadScene(3);
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
