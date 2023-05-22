using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

public class SceneLoader : MonoBehaviour
{
    public static SceneLoader instance;
    
    [SerializeField] private int currentSceneToLoad;
    [SerializeField] private int loadingSceneIndex;
    [Space(10)]
    [SerializeField] private float timeToIdle;
    
    private Animator _animator;

    private void Awake()
    {
        if (instance == null)
        {
            instance = this;
            DontDestroyOnLoad(this);
        }
        else {
            Destroy(gameObject);
            return;
        }
        
        _animator = GetComponent<Animator>();
    }

    public void SetupLoadScene(int sceneID)
    {
        Time.timeScale = 1;
        currentSceneToLoad = sceneID;

        if (sceneID != SceneManager.GetActiveScene().buildIndex)
        {
            Debug.Log("New scene?");
            EventManager.Trigger("OnNewSceneLoaded");
        }
        
        DoFadeIn();
    }

    public void StartNewSceneLoad()
    {
        _animator.Play("NoFade");
        StartCoroutine(DoAsyncSceneLoading());
    }
    
    public IEnumerator DoAsyncSceneLoading()
    {
        yield return new WaitForSeconds(timeToIdle);
        
        AsyncOperation operation = SceneManager.LoadSceneAsync(currentSceneToLoad);

        while (!operation.isDone)
        {
            yield return null;
        }

        DoFadeOut();
        yield return null;
    }

    public void ReloadScene()
    {
        SetupLoadScene(SceneManager.GetActiveScene().buildIndex);
    }

    #region FADE AREA

    public void OnFadeOutFinished()
    {
        _animator.Play("NoFade");
    }

    public void OnFadeInFinished()
    {
        SceneManager.LoadScene(loadingSceneIndex);
    }

    public void DoFadeOut()
    {
        _animator.Play("FadeOut");
    }

    public void DoFadeIn()
    {
        _animator.Play("FadeIn");
    }
    
    IEnumerator DoLittleIdle()
    {
        yield return new WaitForSeconds(timeToIdle);
        SceneLoader.instance.StartNewSceneLoad();
        yield return null;
    }

    #endregion
}
