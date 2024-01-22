using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class MusicListToggler : GenericObject
{
    [SerializeField] private List<AudioSource> _allSongs;
    
    private List<AudioClip> _allClips;
    private List<int> _musicIDs,_shuffledMusic, _shuffledIDs;
    
    bool hasBeenTriggered = false;
    private bool isPlaying = false;
    private float currentSongTimer, totalSongTimer;
    private int currentSong = -1;
    
    private void Awake()
    {
        UpdateManager.instance.AddObject(this);
    }

    public override void OnStart()
    {
        _musicIDs = new List<int>();
        _allClips = new List<AudioClip>();
        
        foreach (var audioSource in _allSongs)
        {
            _allClips.Add(audioSource.clip);
            _musicIDs.Add(SoundManager.instance.AddMusicSource(audioSource));
        }
    }

    public override void OnUpdate()
    {
        if(isPlaying) PlayMusic();
    }

    void ShuffleMusic()
    {
        _shuffledIDs = new List<int>();
        _shuffledMusic = new List<int>();
        
        for (int i = 0; i < _allSongs.Count; i++)
        {
            int rand = UnityEngine.Random.Range(0, _allSongs.Count);

            while (_shuffledMusic.Contains(_musicIDs[rand]))
            {
                rand = UnityEngine.Random.Range(0, _allSongs.Count);
            }
            
            _shuffledMusic.Add(_musicIDs[rand]);
            _shuffledIDs.Add(rand);
        }
        
        currentSongTimer = 0f;
        totalSongTimer = -1f;
        isPlaying = true;
    }

    void PlayMusic()
    {
        if (currentSongTimer >= totalSongTimer)
        {
            currentSong++;
            
            if (currentSong >= _shuffledMusic.Count) currentSong = 0;

            totalSongTimer = _allClips[_shuffledIDs[currentSong]].length;
            currentSongTimer = 0f;
            
            SoundManager.instance.PlayMusicByInt(_shuffledMusic[currentSong]);
        }

        currentSongTimer += Time.deltaTime;
    }
    
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.tag == "Player" && !hasBeenTriggered)
        {
            hasBeenTriggered = true;
            SoundManager.instance.StopAllMusic();
            ShuffleMusic();
        }
    }
}
