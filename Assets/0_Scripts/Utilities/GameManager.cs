using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using System.Linq;
using UnityEngine.Rendering;
using UnityEngine.Serialization;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance;
    [SerializeField] private List<Camera> _myCameras = new List<Camera>();
    [SerializeField] private bool _isMainScene;
    [SerializeField] private Animator _fadeAnimator;

    [SerializeField] private int _actualScene = 0;
    public bool isLoading = false;

    private void Awake()
    {
        if (Instance != null)
        {
            for (int i = 0; i < _myCameras.Count; i++)
            {
                Destroy(_myCameras[i].gameObject);
            }
            
            Destroy(_fadeAnimator.gameObject);

            Destroy(gameObject);
        }
        else
        {
            Instance = this;
        }
    }

    private void Start()
    {
        if (_isMainScene)
            ChangeScene(0, false);
        else
        {
            _fadeAnimator.Play("FadeOut");
            UpdateManager._instance.OnSceneLoad();
        }
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.M))
        {
            ChangeScene(2);
        }
    }

    private Model _player;

    public Model Player
    {
        get
        {
            if (!_player) _player = FindObjectOfType<Model>();
            return _player;
        }
        set
        {
            if (!_player) _player = value;
        }
    }

    private Assistant _assistant;

    public Assistant Assistant
    {
        get
        {
            if (!_assistant) _assistant = FindObjectOfType<Assistant>();
            return _assistant;
        }
        set
        {
            if (!_assistant) _assistant = value;
        }
    }


    #region Scenes Funcs

    public void ChangeScene(int indexToLoad, bool fadeIn = true)
    {
        if (isLoading) return;
        if (!InGameSceneManager.instace.HaveTheScene(indexToLoad)) return;

        EventManager.Trigger("OnResetTriggerLevel");
        InGameSceneManager.instace.SetNextScene(indexToLoad);
        isLoading = true;
        _actualScene = indexToLoad;

        StartCoroutine(SceneLoader(fadeIn));
    }

    public void NextScene(bool fadeIn = true)
    {
        if (isLoading) return;
        if (!InGameSceneManager.instace.HaveTheScene(_actualScene + 1)) return;

        EventManager.Trigger("OnResetTriggerLevel");
        _actualScene++;

        InGameSceneManager.instace.SetNextScene(_actualScene);
        isLoading = true;

        StartCoroutine(SceneLoader(fadeIn));
    }

    public void ReloadScene()
    {
        InGameSceneManager.instace.SetNextScene(_actualScene);
        StartCoroutine(SceneLoader(true));
    }

    private IEnumerator SceneLoader(bool needFadeIn)
    {
        if (needFadeIn)
        {
            _fadeAnimator.Play("FadeIn");
            yield return new WaitForSeconds(_fadeAnimator.GetCurrentAnimatorStateInfo(0).length);
        }

        yield return new WaitForEndOfFrame();

        _myCameras[0].transform.parent = transform;

        if (InGameSceneManager.instace.HasLoadingScene(_actualScene))
        {
            InGameSceneManager.instace.SetLoadingScreen(true);
            yield return new WaitUntil(() => InGameSceneManager.instace.loadingScreenOperation.progress > 0.85f);
            _fadeAnimator.Play("FadeOut");
            yield return new WaitForSeconds(_fadeAnimator.GetCurrentAnimatorStateInfo(0).length);
        }

        UpdateManager._instance.OnSceneUnload();
        EventManager.ResetEventDictionary();
        SoundManager.instance.StopAllSounds();
        SoundManager.instance.StopAllMusic();

        InGameSceneManager.instace.UnloadScene();

        yield return new WaitForEndOfFrame();
        yield return new WaitUntil(() => !InGameSceneManager.instace.isLoading);
        yield return new WaitForEndOfFrame();

        InGameSceneManager.instace.LoadScene();

        yield return new WaitForEndOfFrame();
        yield return new WaitUntil(() => !InGameSceneManager.instace.isLoading);
        yield return new WaitForFrames(2);

        UpdateManager._instance.OnSceneLoad();
        yield return new WaitForEndOfFrame();

        if (InGameSceneManager.instace.HasLoadingScene(_actualScene))
        {
            _fadeAnimator.Play("FadeIn");
            yield return new WaitForSeconds(_fadeAnimator.GetCurrentAnimatorStateInfo(0).length);
            InGameSceneManager.instace.SetLoadingScreen(false);
            yield return new WaitUntil(() => InGameSceneManager.instace.loadingScreenOperation.isDone);
            InGameSceneManager.instace.loadingScreenOperation = null;
        }

        _fadeAnimator.Play("FadeOut");
        yield return new WaitForSeconds(_fadeAnimator.GetCurrentAnimatorStateInfo(0).length);

        isLoading = false;

        //Start
    }

    public void FadeIn()
    {
        StartCoroutine(IE_FadeIn());
    }

    IEnumerator IE_FadeIn()
    {
        _fadeAnimator.Play("FadeIn");
        yield return new WaitForSeconds(_fadeAnimator.GetCurrentAnimatorStateInfo(0).length);
        _fadeAnimator.Play("BlackScreen");
    }

    #endregion


    #region Camera

    public Camera GetCamera()
    {
        return _myCameras[0];
    }

    public Camera SetCameraParent(Transform parent)
    {
        _myCameras[0].transform.position = parent.position;
        _myCameras[0].transform.rotation = parent.rotation;
        _myCameras[0].transform.parent = parent;

        return _myCameras[0];
    }

    public Camera SetCameraPropieties(Color backgroundColor, int newLayer = 0,
        CameraClearFlags clearFlag = CameraClearFlags.Skybox, bool isOrthographic = false, float orthographicSize = 0)
    {
        _myCameras[0].gameObject.layer = newLayer;
        _myCameras[0].clearFlags = clearFlag;
        _myCameras[0].backgroundColor = backgroundColor;

        _myCameras[0].orthographic = isOrthographic;
        if (isOrthographic)
        {
            Debug.Log("aca");
            _myCameras[0].orthographicSize = orthographicSize;
        }

        return _myCameras[0];
    }

    #endregion

    public void PauseGame()
    {
        SoundManager.instance.PauseAllSounds();
        UpdateManager._instance.ChangeGameState(true);
    }

    public void ResumeGame()
    {
        SoundManager.instance.ResumeAllSounds();
        UpdateManager._instance.ChangeGameState(false);
    }
}