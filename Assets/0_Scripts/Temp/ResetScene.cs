using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace TEMP_GROUP
{
    public class ResetScene : MonoBehaviour
    {
        private void Start()
        {
            EventManager.UnSubscribe("OnReturnToMainMenu", ReturnToMenu);
            EventManager.Subscribe("OnReturnToMainMenu", ReturnToMenu);
        }

        private void LateUpdate()
        {
            if (Input.GetKey(KeyCode.R))
            {
                ReloadCurrentScene();
            }
        }

        private void OnTriggerEnter(Collider other)
        {
            if (other.gameObject.tag == "Player")
            {
                ReloadCurrentScene();
            }
        }

        void ReloadCurrentScene()
        {
            EventManager.ResetEventDictionary();
            SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
        }

        private void ReturnToMenu(object[] parameters)
        {
            SceneManager.LoadScene(0);
        }
    }
}
