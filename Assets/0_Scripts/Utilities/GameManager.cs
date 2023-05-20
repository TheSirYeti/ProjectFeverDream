using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class GameManager : MonoBehaviour
{
    public static GameManager instace;

    void Awake()
    {
        instace = this;
    }

    private Model _player;
    public Model Player 
    {
        get { if (!_player) _player = FindObjectOfType<Model>(); return _player; }
        set { if (!_player) _player = value; }
    }

    private Assistant _assistant;
    public Assistant Assistant
    {
        get { if (!_assistant) _assistant = FindObjectOfType<Assistant>(); return _assistant; }
        set { if(!_assistant) _assistant = value; }
    }
}
