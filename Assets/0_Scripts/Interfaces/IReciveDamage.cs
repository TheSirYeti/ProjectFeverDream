using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public interface IReciveDamage
{
    public void DoDamage(float dmg, Vector3 enemyPos);
}
