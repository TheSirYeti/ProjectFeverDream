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

    private Animator _animator;

    private void Awake()
    {
        if (instance == null)
            instance = this;
        else Destroy(gameObject);
    }

    public void SetupLoadScene(object[] parameters)
    {
        currentSceneToLoad = (int)parameters[0];
        DoFadeIn();
    }

    public IEnumerator DoAsyncSceneLoading()
    {
        AsyncOperation operation = SceneManager.LoadSceneAsync(currentSceneToLoad);

        while (!operation.isDone)
        {
            yield return null;
        }

        DoFadeOut();
        yield return null;
    }


    #region FADE AREA

    public void OnFadeOutFinished()
    {
        _animator.Play("NoFade");
        StartCoroutine(DoAsyncSceneLoading());
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

    #endregion
}
