using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class FabrikSolverIK : MonoBehaviour
{
    [SerializeField] private Transform[] bones;
    private float[] bonesleghts;

    [SerializeField] private int solverInterations;
    [SerializeField] private Transform targetIK;

    private void Start()
    {
        bonesleghts = new float[bones.Length];

        //Calculo la longitud de cada hueso
        for (int i = 0; i < bones.Length; i++)
        {
            if (i < bones.Length - 1)
                bonesleghts[i] = (bones[i + 1].position - bones[i].position).magnitude;
            else
                bonesleghts[i] = 0f; // Si es el ultimo hueso, longitud es 0
        }
    }

    void Update()
    {
        SolverIK();
    }

    private void SolverIK()
    {
        Vector3[] finalBonesPosition = new Vector3[bones.Length];

        // Guardo las posiciones actuales de cada hueso
        for(int i = 0;i < bones.Length; i++)
        {
            finalBonesPosition[i] = bones[i].position;
        }

        // FABRIK tantas veces como se indica en "solverIterations"
        for (int i = 0; i < solverInterations; i++)
        {
            finalBonesPosition = SolverForwardPosition(SolverInversePosition(finalBonesPosition));
        }

        // Aplico los resultados a cada hueso
        for(int i = 0; i < bones.Length; i++)
        {
            bones[i].position = finalBonesPosition[i];
            //Aplicamos rotaciones
            if (i != bones.Length - 1)
                bones[i].rotation = Quaternion.LookRotation(finalBonesPosition[i + 1] - bones[i].position);

        }
    }

    Vector3[] SolverInversePosition(Vector3[] forwardPosition)
    {
        Vector3[] inversePosition = new Vector3[forwardPosition.Length];

        //Calculo la posiciones "Ideales" desde el ultimo hasta el primer hueso en base las posicion actual.
        for(int i = (forwardPosition.Length - 1); i >=0; i--)
        {
            if(i == forwardPosition.Length - 1)
            {
                //Si es el ultimo hueso, la posicion primera es la misma que la posicion objetivo
                inversePosition[i] = targetIK.position;
            }
            else
            {
                Vector3 posPrimaNext = inversePosition[i+1];
                Vector3 posBaseActual = forwardPosition[i];
                Vector3 direccion = (posBaseActual - posPrimaNext).normalized; //Vector unitario desde posPrimanext a posBaseActual
                float longitud = bonesleghts[i];
                inversePosition[i] = posPrimaNext + (direccion * longitud);
            }
        }

        return inversePosition;
    }

    Vector3[] SolverForwardPosition(Vector3[] inversePosition)
    {
        Vector3[] forwardPosition = new Vector3[inversePosition.Length];
            
        for(int i = 0; i < inversePosition.Length; i++)
        {
            if(i == 0)
            {
                //Si se el primer hueso, la posicion es la misma que posicion del primer hueso base
                inversePosition[i] = bones[0].position;
            }
            else
            {
                Vector3 posPrimaActual = inversePosition[i];
                Vector3 posPrimaSecondPrevious = forwardPosition[i-1];
                Vector3 direccion = (posPrimaActual - posPrimaSecondPrevious).normalized; //Vector unitario desde posPrimaSecondPrevious a posPrimaActual
                float longitud = bonesleghts[i - 1];
                forwardPosition[i] = posPrimaSecondPrevious + (direccion * longitud);
            }
        }

        return forwardPosition;
    }
}
