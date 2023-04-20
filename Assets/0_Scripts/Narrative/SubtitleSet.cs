using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "SubtitleSet", menuName = "ScriptableObjects/SubtitleSet", order = 1)]
public class SubtitleSet : ScriptableObject
{
    public List<VoicelineStruct> allVoicelines;
    
    [Serializable] public struct VoicelineStruct
    {
        public int id;
        public string title;
        public string speaker;
        public float duration;
        public AudioSource sfx;
        [TextArea] public string subtitle;
    }
}
