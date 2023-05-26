using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;
using System.Linq;

public class InGameSceneManager : MonoBehaviour
{
    public static InGameSceneManager _instace;

    [SerializeField] List<SO_Scene> _scenes;

    private SO_Scene _sceneToLoad;
    private SO_Scene _actualScene;

    private AsyncOperation[] asincOperations;

    private Coroutine _actualCoroutine;

    public bool corutineIsOn => _actualCoroutine != null;

    void Awake()
    {
        if (_instace) Destroy(gameObject);

        _instace = this;
    }

    public bool HaveTheScene(int index)
    {
        return _scenes[index];
    }

    public void SetNextScene(int index)
    {
        _sceneToLoad = _scenes[index];
    }

    public void LoadScene()
    {
        _actualCoroutine = StartCoroutine(IE_LoadScene());
    }
    
    private IEnumerator IE_LoadScene()
    {
        _actualScene = _sceneToLoad;
        _sceneToLoad = null;

        asincOperations = new AsyncOperation[_actualScene._unityScenes.Count()];
        for (int i = 0; i < _actualScene._unityScenes.Count(); i++)
        {
            asincOperations[i] = SceneManager.LoadSceneAsync(_actualScene._unityScenes[i].ScenePath, LoadSceneMode.Additive);
        }

        yield return new WaitUntil(() =>
        {
            AsyncOperation[] tempArray = asincOperations.Where(x => x.isDone).ToArray();
            return tempArray.Length == asincOperations.Length;
        });

        _actualCoroutine = null;
    }

    public void UnloadScene()
    {
        _actualCoroutine = StartCoroutine(IE_UnloadScene());
    }

    private IEnumerator IE_UnloadScene()
    {
        asincOperations = new AsyncOperation[_actualScene._unityScenes.Count()];
        for (int i = 0; i < _actualScene._unityScenes.Count(); i++)
        {
            asincOperations[i] = SceneManager.UnloadSceneAsync(_actualScene._unityScenes[i].ScenePath);
        }

        yield return new WaitUntil(() =>
        {
            AsyncOperation[] tempArray = asincOperations.Where(x => x.isDone).ToArray();
            return tempArray.Length == asincOperations.Length;
        });

        _actualCoroutine = null;
    }

}