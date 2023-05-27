using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;

public class SubtitleManager : GenericObject
{
    [Header("SUBTITLE SETTINGS")]
    public SubtitleSet currentSubtitleSet;
    [SerializeField] private Animator animator;
    private bool isLinePlaying = false;

    [Header("SUBTITLE UI PROPERTIES")] 
    [SerializeField] private TextMeshProUGUI subtitles, speaker;

    private void Awake()
    {
        UpdateManager._instance.AddObject(this);
    }
    
    public override void OnStart()
    {
        EventManager.Subscribe("OnVoicelineSetTriggered", SetCurrentVoicelines);
    }

    public void SetCurrentVoicelines(object[] parameters)
    {
        SubtitleSet newSet = (SubtitleSet)parameters[0];

        if (newSet == null) return;
            
        currentSubtitleSet = newSet;

        var allSfx = currentSubtitleSet.allVoicelines.Select(x => x.sfx).ToArray();
        SoundManager.instance.SetNewVoiceSet(allSfx);
        
        //temp?
        StopCoroutine(PlayVoiceline());
        StartCoroutine(PlayVoiceline());
    }

    IEnumerator PlayVoiceline()
    {
        animator.SetBool("isSub", true);
        foreach (var voiceline in currentSubtitleSet.allVoicelines)
        {
            SoundManager.instance.PlayVoiceLineByID(voiceline.id - 1);
            speaker.text = voiceline.speaker;
            subtitles.text = voiceline.subtitle;
            EventManager.Trigger("OnVoiceLineStarted", voiceline.speaker, voiceline.subtitle);
            yield return new WaitForSeconds(voiceline.duration);
        }

        animator.SetBool("isSub", false);
        yield return null;
    }
}