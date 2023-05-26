using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Serialization;

[CreateAssetMenu(fileName = "Generic Audio Clip Set", menuName = "ScriptableObjects/AudioClip")]
public class SO_AudioSet : ScriptableObject
{
    public AudioClip[] actualLevelAudioClip;
    public List<string> audioClipNames;
}
