using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace TEMP_GROUP
{
    public class ResetScene : GenericObject
    {
        public override void OnStart()
        {
            EventManager.UnSubscribe("OnReturnToMainMenu", ReturnToMenu);
            EventManager.Subscribe("OnReturnToMainMenu", ReturnToMenu);
        }

        public override void OnLateUpdate()
        {
            if (Input.GetKey(KeyCode.Alpha0))
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
