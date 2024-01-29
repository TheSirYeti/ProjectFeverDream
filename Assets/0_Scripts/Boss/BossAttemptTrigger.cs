using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class BossAttemptTrigger : GenericObject
{
    private bool hasTriggered = false;
    public int maxReplayValue;
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnStart()
    {

    }

    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player" && !hasTriggered)
        {
            hasTriggered = true;
            //SoundManager.instance.StopAllSounds();
            SoundManager.instance.StopAllMusic();
            SoundManager.instance.StopAllVoiceLines();
            
            DoIntroSequence();
        }
    }

    void DoIntroSequence()
    {
        int replay = PlayerPrefs.GetInt("LevelReplayCounter");

        if (replay > maxReplayValue)
        {
            CutsceneManager.instance.PlayTimeline(1);
            return;
        }
        
        CutsceneManager.instance.PlayTimeline(replay);
    }
}
