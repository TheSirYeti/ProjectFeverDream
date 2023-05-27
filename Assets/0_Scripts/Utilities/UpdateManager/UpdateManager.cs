using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;

    public class UpdateManager : MonoBehaviour, ISceneChanges
    {
        public static UpdateManager _instance;

        private bool _gamePause = false;

        private Dictionary<int, IOnInit> _inits = new Dictionary<int, IOnInit>();
        private Dictionary<int, IOnUpdate> _pausableUpdates = new Dictionary<int, IOnUpdate>();
        private Dictionary<int, IOnUpdate> _continousUpdates = new Dictionary<int, IOnUpdate>();

        private void Awake()
        {
            if (_instance) Destroy(gameObject);

            _instance = this;
        }

        private void Update()
        {
            if (_continousUpdates.Any())
            {
                foreach (var update in _continousUpdates)
                {
                    update.Value.OnUpdate();
                }
            }

            if (_gamePause) return;

            if (_pausableUpdates.Any())
            {
                foreach (var update in _pausableUpdates)
                {
                    update.Value.OnUpdate();
                }
            }
        }

        private void FixedUpdate()
        {
            if (!_continousUpdates.Any()) return;

            foreach (var update in _continousUpdates)
            {
                update.Value.OnFixedUpdate();
            }
            
            if (_gamePause) return;

            if (_pausableUpdates.Any())
            {
                foreach (var update in _pausableUpdates)
                {
                    update.Value.OnFixedUpdate();
                }
            }
        }

        public void OnSceneLoad()
        {
            StartCoroutine(InitScene());
        }

        public void OnSceneUnload()
        {
            _inits = new Dictionary<int, IOnInit>();
            _pausableUpdates = new Dictionary<int, IOnUpdate>();
            _continousUpdates = new Dictionary<int, IOnUpdate>();
        }

        public void AddObject(GenericObject genericObject, int updatePriority = 0, bool isPausable = true)
        {
            _inits.Add(updatePriority, genericObject as IOnInit);
            _inits = _inits.OrderBy(x => x.Key)
                            .ToDictionary(x => x.Key, x => x.Value);

            if (isPausable)
                _pausableUpdates.Add(updatePriority, genericObject as IOnUpdate);
            else
                _continousUpdates.Add(updatePriority, genericObject as IOnUpdate);
                
            
        }

        private IEnumerator InitScene()
        {
            foreach (var init in _inits)
            {
                init.Value.OnAwake();
            }

            yield return new WaitForEndOfFrame();

            foreach (var init in _inits)
            {
                init.Value.OnStart();
            }

            yield return new WaitForEndOfFrame();

            foreach (var init in _inits)
            {
                init.Value.OnLateStart();
            }
        }
    }
