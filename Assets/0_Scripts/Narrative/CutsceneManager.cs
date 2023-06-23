using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Playables;
using UnityEngine.Timeline;

public class CutsceneManager : GenericObject
{
    public static CutsceneManager instance;
    
    [SerializeField] private List<TimelineAsset> allTimelines;
    [SerializeField] private PlayableDirector director;
    [SerializeField] private bool playFirstCutscene = true;
    
    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }

    public override void OnAwake()
    {
        if (instance == null) instance = this;
        else Destroy(gameObject);
    }

    public override void OnStart()
    {
        if (PlayerPrefs.GetInt("CurrentCheckpoint") == 0 && playFirstCutscene)
        {
            director.playableAsset = allTimelines[0];
            director.Play();
        }
    }

    public void PlayTimeline(int timelineID)
    {
        director.playableAsset = allTimelines[timelineID];
        director.Play();
    }

    public void PauseTimeline()
    {
        director.Pause();
    }

    public void ResumeTimeline()
    {
        director.Resume();
    }
}
