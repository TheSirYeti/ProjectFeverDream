using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using System.Linq;

public class InGameSceneManager : MonoBehaviour
{
    public static InGameSceneManager instace;

    [SerializeField] List<SO_Scene> _scenes;
    [SerializeField] private SO_Scene _loadingScene;

    private SO_Scene _sceneToLoad;
    [SerializeField] private SO_Scene _actualScene;

    [SerializeField] private AsyncOperation[] asincOperations;
    public AsyncOperation loadingScreenOperation;

    private Coroutine _actualCoroutine;

    public bool isLoading = false;

    private void Awake()
    {
        if (instace) Destroy(gameObject);

        instace = this;
    }

    public bool HaveTheScene(int index)
    {
        return _scenes[index];
    }

    public bool HasLoadingScene(int index)
    {
        return _scenes[index].hasLoadingScreen;
    }

    public void SetNextScene(int index)
    {
        _sceneToLoad = _scenes[index];
    }

    public void SetLoadingScreen(bool state)
    {
        if (state)
            loadingScreenOperation = SceneManager.LoadSceneAsync(_loadingScene.unityScenes[0].ScenePath, LoadSceneMode.Additive);
        else
            loadingScreenOperation = SceneManager.UnloadSceneAsync(_loadingScene.unityScenes[0].ScenePath);
    }

    public void LoadScene()
    {
        isLoading = true;
        _actualCoroutine = StartCoroutine(IE_LoadScene());
    }

    private IEnumerator IE_LoadScene()
    {
        _actualScene = _sceneToLoad;
        _sceneToLoad = null;

        asincOperations = new AsyncOperation[_actualScene.unityScenes.Count()];
        for (int i = 0; i < _actualScene.unityScenes.Count(); i++)
        {
            asincOperations[i] =
                SceneManager.LoadSceneAsync(_actualScene.unityScenes[i].ScenePath, LoadSceneMode.Additive);
            asincOperations[i].allowSceneActivation = false;
        }

        yield return new WaitUntil(() =>
        {
            AsyncOperation[] tempArray = asincOperations.Where(x => x.progress > 0.85f).ToArray();
            return tempArray.Length == asincOperations.Length;
        });

        for (int i = 0; i < _actualScene.unityScenes.Count(); i++)
        {
            asincOperations[i].allowSceneActivation = true;
        }

        SoundManager.instance.SetNewMusicSet(_actualScene.myMusic);
        SoundManager.instance.SetNewSoundSet(_actualScene.mySFX);
        GameManager.Instance.SetCameraPropieties(_actualScene.cameraSettings.newLayer,
            _actualScene.cameraSettings.clearFlag);
        
        _actualCoroutine = null;
        isLoading = false;
    }

    public void UnloadScene()
    {
        if (!_actualScene) return;
        
        isLoading = true;
        _actualCoroutine = StartCoroutine(IE_UnloadScene());
    }

    private IEnumerator IE_UnloadScene()
    {
        asincOperations = new AsyncOperation[_actualScene.unityScenes.Count()];
        for (int i = 0; i < _actualScene.unityScenes.Count(); i++)
        {
            asincOperations[i] = SceneManager.UnloadSceneAsync(_actualScene.unityScenes[i].ScenePath);
            asincOperations[i].allowSceneActivation = false;
        }

        yield return new WaitUntil(() =>
        {
            AsyncOperation[] tempArray = asincOperations.Where(x => x.progress > 0.85f).ToArray();
            return tempArray.Length == asincOperations.Length;
        });

        for (int i = 0; i < _actualScene.unityScenes.Count(); i++)
        {
            asincOperations[i].allowSceneActivation = true;
        }

        isLoading = false;
        _actualCoroutine = null;
    }
}