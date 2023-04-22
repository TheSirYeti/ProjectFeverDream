using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using UnityEngine;

public class SubtitleManager : MonoBehaviour
{
    public SubtitleSet currentSubtitleSet;
    [SerializeField] private Animator animator;
    private bool isLinePlaying = false;
    
    public void SetCurrentVoicelines(object[] parameters)
    {
        SubtitleSet newSet = (SubtitleSet)parameters[0];

        if (newSet != null)
            currentSubtitleSet = newSet;

        var allSfx = currentSubtitleSet.allVoicelines.Select(x => x.sfx).ToArray();
        //TODO: llamar SoundManager para mandar los sfx
    }

    IEnumerator PlayVoiceline()
    {
        animator.SetBool("isSub", true);
        foreach (var voiceline in currentSubtitleSet.allVoicelines)
        {
            //TODO: Play voiceline en SoundManager
            EventManager.Trigger("OnVoiceLineStarted", voiceline.speaker, voiceline.subtitle);
            yield return new WaitForSeconds(voiceline.duration);
        }

        animator.SetBool("isSub", false);
        yield return null;
    }
}