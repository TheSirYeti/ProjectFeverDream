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

    private void Awake()
    {
        if (Instance != null)
            Destroy(gameObject);

        Instance = this;
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
        if (!InGameSceneManager._instace.HaveTheScene(indexToLoad)) return;
        
        InGameSceneManager._instace.SetNextScene(indexToLoad);
        
        StartCoroutine(SceneLoader());
    }

    private IEnumerator SceneLoader()
    {
        UpdateManager._instance.OnSceneUnload();
        
        InGameSceneManager._instace.UnloadScene();
        
        yield return new WaitForEndOfFrame();
        yield return new WaitUntil(() => !InGameSceneManager._instace.corutineIsOn);
        yield return new WaitForEndOfFrame();

        InGameSceneManager._instace.LoadScene();
        
        yield return new WaitForEndOfFrame();
        yield return new WaitUntil(() => !InGameSceneManager._instace.corutineIsOn);
        yield return new WaitForEndOfFrame();

        UpdateManager._instance.OnSceneLoad();

        yield return new WaitForEndOfFrame();

        List<Camera> allCameras = Camera.allCameras.ToList();

        
        foreach (var camera in _myCameras)
        {
            allCameras.Remove(camera);
        }

        foreach (var camera in allCameras)
        {
            Destroy(camera.gameObject);
        }
        //Start
    }
}