using UnityEngine;

public interface ITakeDamage
{
    public void TakeDamage(string partDamaged, float dmg, Vector3 hitOrigin, OnDeathKnockBacks onDeathKnockback = OnDeathKnockBacks.NOKNOCKBACK, bool hasKnockback = false);
    public bool IsAlive();
}
