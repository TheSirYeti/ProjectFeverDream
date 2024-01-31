using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using TMPro;
using UnityEngine;
using Random = UnityEngine.Random;

public class SubtitleManager : GenericObject
{
    [Header("SUBTITLE SETTINGS")]
    public SubtitleSet currentSubtitleSet;
    public SubtitleSet defaultSet;
    [SerializeField] private Animator animator;
    private int currentVoicelineID;
    private bool isLinePlaying = false;
    private float currentSubtitleLength;

    [Header("SUBTITLE UI PROPERTIES")] 
    [SerializeField] private TextMeshProUGUI subtitles, speaker;

    [Header("ASSISTANT SUBS")] 
    [SerializeField] private List<SubtitleSet> interactSubs;
    [SerializeField] private List<SubtitleSet> eatSubs;

    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }
    
    public override void OnStart()
    {
        currentSubtitleSet = defaultSet;
        EventManager.Subscribe("OnVoicelineSetTriggered", SetCurrentVoicelines);
        EventManager.Subscribe("OnVoicelineStopTriggered", StopCurrentVoiceline);
        EventManager.Subscribe("OnAssistantInteractDialogueTriggered", PlayInteractSound);
        EventManager.Subscribe("OnAssistantEatDialogueTriggered", PlayEatSound);
    }

    public override void OnUpdate()
    {
        if (isLinePlaying)
        {
            currentSubtitleLength -= Time.deltaTime;
            if (currentSubtitleLength <= 0)
            {
                PlayNextVoiceline();
            }
        }
    }

    public void StopVoicelines()
    {
        SoundManager.instance.StopAllVoiceLines();
        animator.SetBool("isSub", false);
        currentSubtitleSet = defaultSet;
        currentSubtitleLength = 0;
        currentVoicelineID = -1;
        isLinePlaying = false;
    }
    
    public void SetCurrentVoicelines(object[] parameters)
    {
        SubtitleSet newSet = (SubtitleSet)parameters[0];

        if (newSet == null || 
            (currentSubtitleSet != null && !currentSubtitleSet.isInterruptible)
            || currentSubtitleSet != null && currentSubtitleSet != defaultSet && newSet.isOneLiner) 
            return;

        StopVoicelines();

        currentSubtitleSet = newSet;

        var allSfx = currentSubtitleSet.allVoicelines.Select(x => x.sfx).ToArray();
        SoundManager.instance.SetNewVoiceSet(allSfx);

        animator.SetBool("isSub", true);
        PlayNextVoiceline();
        
        isLinePlaying = true;
    }

    public void StopCurrentVoiceline(object[] parameters)
    {
        StopVoicelines();
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

    void PlayNextVoiceline()
    {
        currentVoicelineID++;

        if (currentVoicelineID >= currentSubtitleSet.allVoicelines.Count)
        {
            StopVoicelines();
            return;
        }
        
        SubtitleSet.VoicelineStruct voiceline = currentSubtitleSet.allVoicelines[currentVoicelineID];
        
        SoundManager.instance.PlayVoiceLineByID(voiceline.id - 1);
        speaker.text = voiceline.speaker;
        subtitles.text = voiceline.subtitle;
        EventManager.Trigger("OnVoiceLineStarted", voiceline.speaker, voiceline.subtitle);
        currentSubtitleLength = voiceline.duration;
    }

    #region ASSISTANT FUNCS

    void PlayInteractSound(object[] parameters)
    {
        int randID = Random.Range(0, interactSubs.Count);

        EventManager.Trigger("OnVoicelineSetTriggered", interactSubs[randID]);
    }
    
    void PlayEatSound(object[] parameters)
    {
        int randID = Random.Range(0, eatSubs.Count);

        EventManager.Trigger("OnVoicelineSetTriggered", eatSubs[randID]);
    }

    #endregion
}