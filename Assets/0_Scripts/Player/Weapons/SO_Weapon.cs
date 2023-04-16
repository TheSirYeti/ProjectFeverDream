using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[CreateAssetMenu(fileName = "Weapon SO", menuName = ("ScriptableObjects / Weapon"))]
public class SO_Weapon : ScriptableObject
{
    [Header("-== WEAPON ID ==-")]
    public int weaponID;

    [Header("-== BASIC BOOLS ==-")]
    public bool isMelee;
    public bool canADS;

    [Header("-== ATTACK STATS ==-")]
    public float dmg;
    public float fireRate;

    [Header("-== BULLETS STATS ==-")]
    public GameObject _bulletPrefab;
    public int maxBulletsInMagazine;
    public int maxBulletsInInventory;
    public int initialBulletsInInventory;

    [Header("-== FEEDBACK ==-")]
    public ParticleSystem particleShoot;
    public GameObject lightMuzzle;

    [Header("-== ANIMATORS VARS ==-")]
    public string onClickAnimatorTrigger;
    public string onReleaseAnimatorTrigger;
}
