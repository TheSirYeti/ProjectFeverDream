using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LogoSceneLogic : MonoBehaviour
{
    [SerializeField] private Animator _animator;
    [SerializeField] private float firstSongSection;
    [SerializeField] private float secondSongSection;
    [SerializeField] private int nextSceneToLoad;

    private void Start()
    {
        StartCoroutine(DoIntroCycle());
    }

    private IEnumerator DoIntroCycle()
    {
        SoundManager.instance.PlayMusic(MusicID.INTRO_JINGLE);
        yield return new WaitForSeconds(firstSongSection);
        _animator.Play("FadeInLogo");
        yield return new WaitForSeconds(secondSongSection);
        SceneLoader.instance.SetupLoadScene(nextSceneToLoad);
        yield return null;
    }
}
