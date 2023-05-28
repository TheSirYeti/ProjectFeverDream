using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class LogoSceneLogic : GenericObject
{
    [SerializeField] private Transform _cameraPos;
    [SerializeField] private Canvas _canvas;
    
    [SerializeField] private Animator _animator;
    [SerializeField] private float firstSongSection;
    [SerializeField] private float secondSongSection;
    [SerializeField] private int nextSceneToLoad;

    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }
    
    public override void OnAwake()
    {
        _canvas.worldCamera = GameManager.Instance.SetCameraParent(_cameraPos);
    }

    public override void OnStart()
    {
        StartCoroutine(DoIntroCycle());
    }

    public override void OnUpdate()
    {
        if (Input.GetKey(KeyCode.Return) || Input.GetKey(KeyCode.Space))
        {
            StopCoroutine(DoIntroCycle());
            SoundManager.instance.StopAllMusic();
            SoundManager.instance.StopAllSounds();
            GameManager.Instance.ChangeScene(nextSceneToLoad);
        }
    }

    private IEnumerator DoIntroCycle()
    {
        SoundManager.instance.PlayMusic(MusicID.INTRO_JINGLE);
        yield return new WaitForSeconds(firstSongSection);
        //TODO: Change for game manager fade in
        _animator.Play("FadeInLogo");
        yield return new WaitForSeconds(secondSongSection);
        GameManager.Instance.ChangeScene(nextSceneToLoad);
        yield return null;
    }
}
