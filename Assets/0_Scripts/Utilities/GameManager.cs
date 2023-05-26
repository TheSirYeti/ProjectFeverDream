using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using System.Linq;
using _0_Scripts.Utilities;

public class GameManager : MonoBehaviour
{
    public static GameManager Instance;
    [SerializeField] private List<Camera> _myCameras = new List<Camera>();

    private int _actualScene = 0;
    private bool _isLoading = false;

    private void Awake()
    {
        if (Instance != null)
            Destroy(gameObject);

        Instance = this;
    }

    private void Start()
    {
        ChangeScene(0);
    }

    private void Update()
    {
        if (Input.GetKeyDown(KeyCode.K))
            ChangeScene(0);
        if (Input.GetKeyDown(KeyCode.L))
            ChangeScene(1);
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

    public void ChangeScene(int indexToLoad)
    {
        if(_isLoading) return;
        if (!InGameSceneManager.instace.HaveTheScene(indexToLoad)) return;
        
        InGameSceneManager.instace.SetNextScene(indexToLoad);
        _isLoading = true;
        _actualScene = indexToLoad;
        
        StartCoroutine(SceneLoader());
    }

    public void NextScene()
    {
        if(_isLoading) return;
        if (!InGameSceneManager.instace.HaveTheScene(_actualScene + 1)) return;
        
        _actualScene++;
        
        InGameSceneManager.instace.SetNextScene(_actualScene);
        _isLoading = true;
        
        StartCoroutine(SceneLoader());
    }

    private IEnumerator SceneLoader()
    {
        InGameSceneManager.instace.SetLoadingScreen(true);
        
        UpdateManager._instance.OnSceneUnload();
        
        InGameSceneManager.instace.UnloadScene();
        
        yield return new WaitForEndOfFrame();
        yield return new WaitUntil(() => !InGameSceneManager.instace.corutineIsOn);
        yield return new WaitForEndOfFrame();

        InGameSceneManager.instace.LoadScene();
        
        yield return new WaitForEndOfFrame();
        yield return new WaitUntil(() => !InGameSceneManager.instace.corutineIsOn);
        yield return new WaitForEndOfFrame();
        
        InGameSceneManager.instace.SetLoadingScreen(false);

        List<Camera> allCameras = Camera.allCameras.ToList();
        
        foreach (var camera in _myCameras)
        {
            allCameras.Remove(camera);
        }

        foreach (var camera in allCameras)
        {
            Destroy(camera.gameObject);
        }
        
        yield return new WaitForEndOfFrame();
        
        UpdateManager._instance.OnSceneLoad();

        _isLoading = false;

        //Start
    }
}