using System;
using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using UnityEngine.SceneManagement;

namespace TEMP_GROUP
{
    public class ResetScene : MonoBehaviour
    {
        private void LateUpdate()
        {
            if (Input.GetKey(KeyCode.R))
            {
                SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
            }

            if (Input.GetKey(KeyCode.Escape))
            {
                Application.Quit();
            }

            if (Input.GetKey(KeyCode.Alpha1))
            {
                SceneManager.LoadScene(0);
            }
            
            if (Input.GetKey(KeyCode.Alpha2))
            {
                SceneManager.LoadScene(1);
            }
            
        }

        private void OnTriggerEnter(Collider other)
        {
            if (other.gameObject.tag == "Player")
            {
                SceneManager.LoadScene(SceneManager.GetActiveScene().buildIndex);
            }
        }
    }
}
