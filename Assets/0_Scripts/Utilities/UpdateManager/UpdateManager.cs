using System.Collections;
using System.Collections.Generic;
using UnityEngine;
using System;
using System.Linq;

    public class UpdateManager : MonoBehaviour, ISceneChanges
    {
        public static UpdateManager _instance;

        private bool _gamePause = false;

        private List<GenericObject> _allObjects = new List<GenericObject>();

        private List<IOnInit> _inits = new List<IOnInit>();
        private List<IOnUpdate> _pausableUpdates = new List<IOnUpdate>();
        private List<IOnUpdate> _continousUpdates = new List<IOnUpdate>();

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
                    update.OnUpdate();
                }
            }

            if (_gamePause) return;

            if (_pausableUpdates.Any())
            {
                foreach (var update in _pausableUpdates)
                {
                    update.OnUpdate();
                }
            }
        }

        private void FixedUpdate()
        {
            if (!_continousUpdates.Any()) return;

            foreach (var update in _continousUpdates)
            {
                update.OnFixedUpdate();
            }
            
            if (_gamePause) return;

            if (_pausableUpdates.Any())
            {
                foreach (var update in _pausableUpdates)
                {
                    update.OnFixedUpdate();
                }
            }
        }

        public void OnSceneLoad()
        {
            StartCoroutine(InitScene());
        }

        public void OnSceneUnload()
        {
            _inits = new List<IOnInit>();
            _pausableUpdates = new List<IOnUpdate>();
            _continousUpdates = new List<IOnUpdate>();
        }

        public void AddObject(GenericObject genericObject)
        {
            _allObjects.Add(genericObject);
            _allObjects = _allObjects.OrderBy(x => x.priority).ToList();

            _inits = _allObjects.Select(x => x as IOnInit).ToList();

            _pausableUpdates = _allObjects.Where(x => x.isPausable).Select(x => x as IOnUpdate).ToList();
            _continousUpdates = _allObjects.Where(x => !x.isPausable).Select(x => x as IOnUpdate).ToList();
        }

        private IEnumerator InitScene()
        {
            foreach (var init in _inits)
            {
                init.OnAwake();
            }

            yield return new WaitForEndOfFrame();

            foreach (var init in _inits)
            {
                init.OnStart();
            }

            yield return new WaitForEndOfFrame();

            foreach (var init in _inits)
            {
                init.OnLateStart();
            }
        }
    }
