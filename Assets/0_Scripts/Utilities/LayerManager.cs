using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class LayerManager
{
    // LAYERS
    public static int L_PLAYER = 3;
    public static int L_FLOOR = 6;
    public static int L_WALL = 7;
    public static int L_NODE = 8;
    public static int L_INTERACT = 10;
    public static int L_ENEMY = 11;
    public static int L_PICKUP = 14;
    public static int L_USABLE = 15;
    public static int L_PROP = 17;
    public static int L_PATHFINDINGOBSTACLE = 13;
    
    // SINGLE LAYER MASK
    public static LayerMask LM_PLAYER = 1 << L_PLAYER;
    public static LayerMask LM_FLOOR = 1 << L_FLOOR;
    public static LayerMask LM_WALL = 1 << L_WALL;
    public static LayerMask LM_NODE = 1 << L_NODE;
    public static LayerMask LM_INTERACT = 1 << L_INTERACT;
    public static LayerMask LM_ENEMY = 1 << L_ENEMY;
    public static LayerMask LM_PICKUP = 1 << L_PICKUP;
    public static LayerMask LM_USABLE = 1 << L_USABLE;
    public static LayerMask LM_PROP = 1 << L_PROP;
    public static LayerMask LM_PATHFINDINGOBSTACLE = (1 << L_PATHFINDINGOBSTACLE);
    
    // COMBINE LAYER MASK
    public static LayerMask LM_ALLINTERACTS = LM_INTERACT | LM_PICKUP | LM_USABLE;
    public static LayerMask LM_OBSTACLE = LM_WALL | LM_FLOOR;
    public static LayerMask LM_NODEOBSTACLE = (LM_PROP | LM_WALL);
    public static LayerMask LM_ALLOBSTACLE = (LM_PROP | LM_WALL | LM_FLOOR );
    public static LayerMask LM_ENEMYSIGHT = (LM_PROP | LM_WALL | LM_FLOOR | LM_PATHFINDINGOBSTACLE);
    public static LayerMask LM_WEAPONSTARGETS = (LM_FLOOR | LM_WALL | LM_ENEMY | LM_PROP);
}
