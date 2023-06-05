using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public static class LayerManager
{
    // LAYERS
    public static int L_FLOOR = 6;
    public static int L_WALL = 7;
    public static int L_NODE = 8;
    public static int L_PROP = 17;
    
    // SIGLE LAYER MASK
    public static LayerMask LM_FLOOR = 1 << L_FLOOR;
    public static LayerMask LM_WALL = 1 << L_WALL;
    public static LayerMask LM_NODE = 1 << L_NODE;
    public static LayerMask LM_PROP = 1 << L_PROP;
    
    // COMBINE LAYER MASK
    public static LayerMask LM_Obstacle = LM_WALL | LM_FLOOR;
    public static LayerMask LM_NodeObstacles = (LM_PROP | LM_WALL);
}
