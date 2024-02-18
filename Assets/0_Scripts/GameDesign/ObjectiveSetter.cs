using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class ObjectiveSetter : GenericObject
{
    [SerializeField] private string _newObjectiveTitle, _newObjectiveDescription;

    public void SetNewObjective()
    {
        EventManager.Trigger("ChangeObjective", _newObjectiveTitle, _newObjectiveDescription);
    }
}
