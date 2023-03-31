using System.Collections;
using System.Collections.Generic;
using System.Data.SqlTypes;
using UnityEngine;


//Modelos y Algoritmos 1 / Aplicacion de Motores 2 - JUAN PABLO RSHAID
public class SoundManager : MonoBehaviour
{
    public AudioClip[] sounds;
    public AudioClip[] music;
    public AudioClip[] voiceLine;
    public AudioSource[] sfxChannel;
    public AudioSource[] musicChannel;
    public AudioSource[] voiceLineChannel;

    public float volumeSFX;
    public float volumeMusic;

    public static SoundManager instance;

    void Awake()
    {
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

        if (instance == null)
        {
            instance = this;
            DontDestroyOnLoad(gameObject);
        }
        else
        {
            Destroy(gameObject);
        }


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
        sfxChannel[(int)id].Play();
        sfxChannel[(int)id].loop = loop;
        sfxChannel[(int)id].volume = volumeSFX;
        sfxChannel[(int)id].pitch = pitch;  
    }

    public void PlaySoundByID(int id, bool loop = false, float pitch = 1)
    {
        sfxChannel[id].Play();
        sfxChannel[id].loop = loop;
        sfxChannel[id].volume = volumeSFX;
        sfxChannel[id].pitch = pitch;
    }
    
    public void StopSoundByID(int id)
    {
        sfxChannel[id].Stop();
    }

    public void StopAllSounds()
    {
        for (int i = 0; i < sfxChannel.Length; i++)
        {
            if(sfxChannel[i] != null)
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
    
    public bool isMusicPlaying(MusicID id)
    {
        return musicChannel[(int)id].isPlaying;
    }
    public void PlayMusic(MusicID id, bool loop = false, float pitch = 1)
    {
        musicChannel[(int)id].Play();
        musicChannel[(int)id].loop = loop;
        musicChannel[(int)id].volume = volumeMusic;
        musicChannel[(int)id].pitch = pitch;
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
    HITMARKER,              //0
    ZAP_SHOT,               //1
    PISTOL_SHOT,            //2
    GUN_RELOAD,             //3
    ENEMY_HIT_1,            //4
    BLASTER_RELOAD,         //5
    ENEMY_DEATH,            //6
    ZAP_RELOAD_PLUG,        //7
    ZAP_RELOAD_CHARGE,      //8
    CD_SHOT,                //9
    CD_RELOAD_HOT,          //10
    CD_RELOAD_TWIST,        //11
    PLAYER_STEP_1,          //12
    PLAYER_STEP_2,          //13
    SABER_SLICE,            //14
    ENEMY_HIT_2,            //15
    PLAYER_LOWHEALTH,       //16
    PLAYER_HURT,            //17
    VINYL_RELOAD_1,         //18
    ENEMY_HIT_HEADSHOT,     //19
    ENEMY_HIT_WEAK,         //20
    ROBOT_AWARE_1,          //21
    ROBOT_AWARE_2,          //22
    ROBOT_AWARE_3,          //23
    ROBOT_AWARE_4,          //24
    ROBOT_DEATH_1,          //25
    ROBOT_DEATH_2,          //26
    ROBOT_DEATH_3,          //27
    ROBOT_DEATH_4,          //28
    TANK_SPAWN,             //29
    TANK_HOOK,              //30
    TANK_SHOT_BUILDUP,      //31
    TANK_SHOT_LASER,        //32
    TANK_SHOT_LINE_1,       //33    
    TANK_SHOT_LINE_2,       //34
    TANK_SHOT_LINE_3,       //35
    TANK_HOOK_LINE_1,       //36
    TANK_HOOK_LINE_2,       //37
    TANK_HOOK_LINE_3,       //38
    WAVE_START_1,           //39
    LEVER_FLICK,            //40
    BATTERY_ZONE_COLLECT,   //41
    BATTERY_ZONE_DONE,      //42
    SHOP_ACCEPT,            //43
    SHOP_DENIED,            //44
    TASK_DONE,              //45
    NO_AMMO,                //46
    WAVE_START_2,           //47
    WAVE_START_3,           //48
    SMOG_EXPLOSION,         //49
    SMOG_BUILDUP,           //50
    SMOG_CHASE,             //51
    SMOG_WAVE,              //52
    BUTTON_SIMONSAYS,       //53
    TOGGLE_SIMONSAYS,       //54
    RADIO_ON,               //55
    BASIC_PUNCH,            //56
    BLASTER_OPENHATCH,      //57
    BLASTER_CLOSEHATCH,     //58
    BLASTER_INSERTMAG,      //59
    BLASTER_DROPMAG,        //60
    SCREW_LIGHTBULB,        //61
    PLUG_IN,                //62
    COMPUTER_START,         //63
    WEE,                    //64
}

public enum MusicID
{
    USA,
    MAIN_MENU,
    VIVA_MEXICO_CABRONES,
    USA_NAVIDAD,
    BOSS,
    MAINGAME
}

public enum VoiceLineID
{
    RADIOMAN_1,
    RADIOMAN_2,
    RADIOMAN_3,
    RADIOMAN_4,
    RADIOMAN_5,
    RADIOMAN_6,
    RADIOMAN_7,
    RADIOMAN_8,
    RADIOMAN_9,
    RADIOMAN_10,
    RADIOMAN_11,
    RADIOMAN_12,    
    RADIOMAN_13,
    RADIOMAN_14,
    RADIOMAN_15,
    RADIOMAN_16,
    RADIOMAN_17,
    RADIOMAN_18,
    RADIOMAN_19,
    RADIOMAN_20,
    RADIOMAN_21,
    RADIOMAN_22,
    RADIOMAN_23,
    RADIOMAN_24,
    RADIOMAN_25,
    RADIOMAN_26,
    RADIOMAN_27,
    RADIOMAN_28,
    RADIOMAN_29,
}