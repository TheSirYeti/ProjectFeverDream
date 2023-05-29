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
    [SerializeField] private List<Transform> cameraPos = new List<Transform>();
    [SerializeField] private bool _isMainScene;
    [SerializeField] private Animator _fadeAnimator;

    public InGameSceneManager sceneManager { private get; set; }
    public SoundManager soundManager { private get; set; }
    public UpdateManager updateManager { private get; set; }

    private int _actualScene = 0;
    public bool isLoading = false;

    private void Awake()
    {
        if (Instance != null)
        {
            for (int i = 0; i < _myCameras.Count; i++)
            {
                Destroy(_myCameras[i]);
            }

            Destroy(gameObject);
        }

        Instance = this;
    }

    private void Start()
    {
        if (_isMainScene)
            ChangeScene(0);
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

    public Camera GetCamera()
    {
        return _myCameras[0];
    }

    #region Scenes Funcs

    public void ChangeScene(int indexToLoad)
    {
        if (isLoading) return;
        if (!InGameSceneManager.instace.HaveTheScene(indexToLoad)) return;

        InGameSceneManager.instace.SetNextScene(indexToLoad);
        isLoading = true;
        _actualScene = indexToLoad;

        StartCoroutine(SceneLoader());
    }

    public void NextScene()
    {
        if (isLoading) return;
        if (!InGameSceneManager.instace.HaveTheScene(_actualScene + 1)) return;

        _actualScene++;

        InGameSceneManager.instace.SetNextScene(_actualScene);
        isLoading = true;

        StartCoroutine(SceneLoader());
    }

    private IEnumerator SceneLoader()
    {
        if (_actualScene != 0)
        {
            _fadeAnimator.Play("FadeIn");
            yield return new WaitForSeconds(_fadeAnimator.GetCurrentAnimatorStateInfo(0).length);
            _fadeAnimator.Play("BlackScreen");
        }
        yield return new WaitForEndOfFrame();
        
        _myCameras[0].transform.parent = transform;

        if (InGameSceneManager.instace.HasLoadingScene(_actualScene))
        {
            InGameSceneManager.instace.SetLoadingScreen(true);
            yield return new WaitUntil(() => InGameSceneManager.instace.loadingScreenOperation.progress > 0.85f);
            _fadeAnimator.Play("FadeOut");
            yield return new WaitForSeconds(_fadeAnimator.GetCurrentAnimatorStateInfo(0).length);
            _fadeAnimator.Play("NoFade");
        }

        UpdateManager._instance.OnSceneUnload();

        InGameSceneManager.instace.UnloadScene();

        yield return new WaitForEndOfFrame();
        yield return new WaitUntil(() => !InGameSceneManager.instace.isLoading);
        yield return new WaitForEndOfFrame();

        EventManager.ResetEventDictionary();
        SoundManager.instance.StopAllSounds();
        SoundManager.instance.StopAllMusic();

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
            _fadeAnimator.Play("BlackScreen");
            InGameSceneManager.instace.SetLoadingScreen(false);
            yield return new WaitUntil(() => InGameSceneManager.instace.loadingScreenOperation.isDone);
            InGameSceneManager.instace.loadingScreenOperation = null;
        }

        _fadeAnimator.Play("FadeOut");
        yield return new WaitForSeconds(_fadeAnimator.GetCurrentAnimatorStateInfo(0).length);
        _fadeAnimator.Play("NoFade");

        isLoading = false;

        //Start
    }

    #endregion

    public Camera SetCameraParent(Transform parent)
    {
        _myCameras[0].transform.position = parent.position;
        _myCameras[0].transform.rotation = parent.rotation;
        _myCameras[0].transform.parent = parent;

        return _myCameras[0];
    }

    public Camera SetCameraPropieties(Color backgroundColor, int newLayer = 0, CameraClearFlags clearFlag = CameraClearFlags.Skybox)
    {
        _myCameras[0].gameObject.layer = newLayer;
        _myCameras[0].clearFlags = clearFlag;
        _myCameras[0].backgroundColor = backgroundColor;

        return _myCameras[0];
    }
}