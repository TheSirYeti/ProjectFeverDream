public interface ITakeDamage
{
    public void TakeDamage(string partDamaged, float dmg, bool hasKnockback = false);
    public bool IsAlive();
}
