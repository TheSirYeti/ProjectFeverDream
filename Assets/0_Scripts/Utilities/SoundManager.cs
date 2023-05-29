using System.Collections;
using System.Collections.Generic;
using System.Data.SqlTypes;
using System.Linq;
using UnityEngine;
using UnityEngine.Serialization;


//Modelos y Algoritmos 1 / Aplicacion de Motores 2 - JUAN PABLO RSHAID
public class SoundManager : MonoBehaviour
{
    [Header("Audio Clips")] 
    public AudioClip[] sounds;
    public AudioClip[] music;
    public AudioClip[] voiceLine;
    
    [Header("Audio Source")] 
    public AudioSource[] sfxChannel;
    public AudioSource[] musicChannel;
    public AudioSource[] voiceLineChannel;

    [Header("Volumes")] 
    public float volumeSFX;
    public float volumeMusic;

    [Header("Sound Names")] 
    [SerializeField] private List<string> _actualSfxNames; 
    [SerializeField] private List<string> _actualMusicNames;

    public static SoundManager instance;

    void Awake()
    {
        if (instance != null)
        {
            Destroy(gameObject);
        }
        
        
        if (PlayerPrefs.HasKey("PREFS_VolumeSFX"))
        {
            volumeSFX = PlayerPrefs.GetFloat("PREFS_VolumeSFX");
            volumeMusic = PlayerPrefs.GetFloat("PREFS_VolumeMusic");
        }
        else
        {
            PlayerPrefs.SetFloat("PREFS_VolumeSFX", volumeSFX);
            PlayerPrefs.SetFloat("PREFS_VolumeMusic", volumeSFX);
        }
        
        instance = this;

        sfxChannel = new AudioSource[sounds.Length];
        for (int i = 0; i < sfxChannel.Length; i++)
        {
            sfxChannel[i] = gameObject.AddComponent<AudioSource>();
            sfxChannel[i].clip = sounds[i];
        }

        musicChannel = new AudioSource[music.Length];
        for (int i = 0; i < musicChannel.Length; i++)
        {
            musicChannel[i] = gameObject.AddComponent<AudioSource>();
            musicChannel[i].clip = music[i];
        }
        
        voiceLineChannel = new AudioSource[voiceLine.Length];
        for (int i = 0; i < voiceLineChannel.Length; i++)
        {
            voiceLineChannel[i] = gameObject.AddComponent<AudioSource>();
            voiceLineChannel[i].clip = voiceLine[i];
        }

    }
    
    #region SOUND
    public void SetNewSoundSet(SO_AudioSet newAudioSet)
    {
        _actualSfxNames = newAudioSet.audioClipNames;
        sounds = newAudioSet.actualLevelAudioClip;
        sfxChannel = new AudioSource[sounds.Length];

        for (int i = 0; i < sfxChannel.Length; i++)
        {
            AudioSource actualAudioSource = gameObject.AddComponent<AudioSource>();

            actualAudioSource.playOnAwake = false;
            sfxChannel[i] = actualAudioSource;
            sfxChannel[i].clip = sounds[i];
        }
    }
    
    public int AddSFXSource(AudioSource myAudioSource)
    {
        List<AudioSource> tempList = new List<AudioSource>();

        tempList.AddRange(sfxChannel);
        tempList.Add(myAudioSource);

        sfxChannel = tempList.ToArray();

        return (sfxChannel.Length - 1);
    }

    public bool isSoundPlaying(SoundID id)
    {
        return sfxChannel[(int)id].isPlaying;
    }

    public void PlaySound(SoundID id, bool loop = false, float pitch = 1)
    {
        var actualName = id.ToString();
        
        if(!_actualSfxNames.Contains(actualName)) return;

        var idToPlay = _actualSfxNames.IndexOf(actualName);
        
        sfxChannel[idToPlay].Play();
        sfxChannel[idToPlay].loop = loop;
        sfxChannel[idToPlay].volume = volumeSFX;
        sfxChannel[idToPlay].pitch = pitch;  
    }

    public void PlaySoundByID(string actualName, bool loop = false, float pitch = 1)
    {
        if(!_actualSfxNames.Contains(actualName)) return;

        var idToPlay = _actualSfxNames.IndexOf(actualName);
        
        sfxChannel[idToPlay].Play();
        sfxChannel[idToPlay].loop = loop;
        sfxChannel[idToPlay].volume = volumeSFX;
        sfxChannel[idToPlay].pitch = pitch;
    }
    
    public void StopSoundByID(int id)
    {
        sfxChannel[id].Stop();
    }

    public void StopAllSounds()
    {
        for (int i = 0; i < sfxChannel.Length; i++)
        {
            if(sfxChannel[i])
                sfxChannel[i].Stop();
        }
    }

    public void PauseAllSounds()
    {
        for (int i = 0; i < sfxChannel.Length; i++)
        {
            if(sfxChannel[i] != null)
                sfxChannel[i].Pause();
        }
    }

    public void ResumeAllSounds()
    {
        for (int i = 0; i < sfxChannel.Length; i++)
        {
            if(sfxChannel[i] != null)
                sfxChannel[i].UnPause();
        }
    }

    public void StopSound(SoundID id)
    {
        sfxChannel[(int)id].Stop();
    }

    public void PauseSound(SoundID id)
    {
        sfxChannel[(int)id].Pause();
    }

    public void ResumeSound(SoundID id)
    {
        sfxChannel[(int)id].UnPause();
    }

    public void ToggleMuteSound(SoundID id)
    {
        sfxChannel[(int)id].mute = !sfxChannel[(int)id].mute;
    }
    public void ChangeVolumeSound(float volume)
    {
        volumeSFX = volume;
        for (int i = 0; i < sfxChannel.Length; i++)
        {
            sfxChannel[i].volume = volumeSFX;
        }
        PlayerPrefs.SetFloat("PREFS_VolumeSFX", volume);
    }

    #endregion

    #region MUSIC
    public void SetNewMusicSet(SO_AudioSet newAudioSet)
    {
        _actualMusicNames = newAudioSet.audioClipNames;
        music = newAudioSet.actualLevelAudioClip;
        musicChannel = new AudioSource[music.Length];

        for (int i = 0; i < musicChannel.Length; i++)
        {
            AudioSource actualAudioSource = gameObject.AddComponent<AudioSource>();
            actualAudioSource.playOnAwake = false;

            musicChannel[i] = actualAudioSource;
            musicChannel[i].clip = music[i];
        }
    }

    public int AddMusicSource(AudioSource myAudioSource)
    {
        List<AudioSource> tempList = new List<AudioSource>();

        tempList.AddRange(musicChannel);
        tempList.Add(myAudioSource);

        musicChannel = tempList.ToArray();

        return (musicChannel.Length - 1);
    }
    
    public bool isMusicPlaying(MusicID id)
    {
        return musicChannel[(int)id].isPlaying;
    }
    
    public void PlayMusic(MusicID id, bool loop = false, float pitch = 1)
    {
        var actualName = id.ToString();
        
        if(!_actualMusicNames.Contains(actualName)) return;

        var idToPlay = _actualMusicNames.IndexOf(actualName);
        
        musicChannel[idToPlay].Play();
        musicChannel[idToPlay].loop = loop;
        musicChannel[idToPlay].volume = volumeMusic;
        musicChannel[idToPlay].pitch = pitch;  
    }

    public void StopAllMusic()
    {
        for (int i = 0; i < musicChannel.Length; i++)
        {
            if(musicChannel[i] != null)
                musicChannel[i].Stop();
        }
    }

    public void PauseAllMusic()
    {
        for (int i = 0; i < musicChannel.Length; i++)
        {
            if(musicChannel[i] != null)
                musicChannel[i].Pause();
        }
    }

    public void ResumeAllMusic()
    {
        for (int i = 0; i < musicChannel.Length; i++)
        {
            if(musicChannel[i] != null)
                musicChannel[i].UnPause();
        }
    }

    public void StopMusic(MusicID id)
    {
        musicChannel[(int)id].Stop();
    }

    public void PauseMusic(MusicID id)
    {
        musicChannel[(int)id].Pause();
    }

    public void ResumeMusic(MusicID id)
    {
        musicChannel[(int)id].UnPause();
    }

    public void ToggleMuteMusic(MusicID id)
    {
        musicChannel[(int)id].mute = !musicChannel[(int)id].mute;
    }

    public void ChangeVolumeMusic(float volume)
    {
        volumeMusic = volume;
        for (int i = 0; i < musicChannel.Length; i++)
        {
            musicChannel[i].volume = volumeMusic;
        }
        PlayerPrefs.SetFloat("PREFS_VolumeMusic", volume);
    }
    
    #endregion
    
    #region VOICELINES
    
    public void SetNewVoiceSet(AudioClip[] newVoiceLines)
    {
        voiceLine = newVoiceLines;

        if (voiceLineChannel.Length < voiceLine.Length)
        {
            int actualIndex = voiceLineChannel.Length;

            for (int i = actualIndex; i < voiceLine.Length; i++)
            {
                AudioSource actualAudioSource = gameObject.AddComponent<AudioSource>();
                actualAudioSource.playOnAwake = false;
                AddVoiceLineSource(actualAudioSource);
            }
        }

        for (int i = 0; i < voiceLineChannel.Length; i++)
        {
            voiceLineChannel[i].clip = voiceLine[i];
        } 
    }

    public int AddVoiceLineSource(AudioSource myAudioSource)
    {
        List<AudioSource> tempList = new List<AudioSource>();

        tempList.AddRange(voiceLineChannel);
        tempList.Add(myAudioSource);

        voiceLineChannel = tempList.ToArray();

        return (voiceLineChannel.Length - 1);
    }

    public bool isVoiceLinePlaying(VoiceLineID id)
    {
        return voiceLineChannel[(int)id].isPlaying;
    }

    public void PlayVoiceLine(VoiceLineID id, bool loop = false, float pitch = 1)
    {
        voiceLineChannel[(int)id].Play();
        voiceLineChannel[(int)id].loop = loop;
        voiceLineChannel[(int)id].volume = volumeSFX;
        voiceLineChannel[(int)id].pitch = pitch;  
    }

    public void PlayVoiceLineByID(int id, bool loop = false, float pitch = 1)
    {
        voiceLineChannel[id].Play();
        voiceLineChannel[id].loop = loop;
        voiceLineChannel[id].volume = volumeSFX;
        voiceLineChannel[id].pitch = pitch;
    }

    public void StopAllVoiceLines()
    {
        for (int i = 0; i < voiceLineChannel.Length; i++)
        {
            voiceLineChannel[i].Stop();
        }
    }

    public void PauseAllVoiceLines()
    {
        for (int i = 0; i < voiceLineChannel.Length; i++)
        {
            voiceLineChannel[i].Pause();
        }
    }

    public void ResumeAllVoiceLines()
    {
        for (int i = 0; i < voiceLineChannel.Length; i++)
        {
            voiceLineChannel[i].UnPause();
        }
    }

    public void StopVoiceLine(VoiceLineID id)
    {
        voiceLineChannel[(int)id].Stop();
    }

    public void PauseVoiceLine(VoiceLineID id)
    {
        voiceLineChannel[(int)id].Pause();
    }

    public void ResumeVoiceLine(VoiceLineID id)
    {
        voiceLineChannel[(int)id].UnPause();
    }

    public void ToggleMuteVoiceLine(VoiceLineID id)
    {
        voiceLineChannel[(int)id].mute = !voiceLineChannel[(int)id].mute;
    }
    
    /*public void ChangeVolumeVoiceLine(float volume)
    {
        volumeSFX = volume;
        for (int i = 0; i < sfxChannel.Length; i++)
        {
            voiceLineChannel[i].volume = volumeSFX;
        }
        PlayerPrefs.SetFloat("PREFS_VolumeSFX", volume);
    }*/

    #endregion
}

public enum SoundID
{
    //0
    FOOTSTEP_1, 
    //1
    FOOTSTEP_2, 
    //2
    SLIDE,  
    //3
    BAGUETTE,
    //4
    TEST_TOASTER_DING,
    //5
    BAGUETTE_IMPACT_1,
    //6
    BAGUETTE_IMPACT_2,
    //7
    BAGUETTE_IMPACT_3,
    //8
    BAGUETTE_BREAK,
    //9
    TOASTER_PULL,
    //10
    TOASTER_EJECT,
    //11
    ASSISTANT_SUCK,
    //12
    PLAYER_HURT,
    //13
    ASSISTANT_INTERACT_BUTTON,
    //14
    ASSISTANT_PING,
}

public enum MusicID
{
    TEST_JIGGY,
    INTRO_JINGLE,
    MAINMENU
}

public enum VoiceLineID
{
    
}