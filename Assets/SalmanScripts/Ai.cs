using System;
using UnityEngine;
using UnityEngine.AI;

public class Ai : MonoBehaviour
{
    [SerializeField]private Transform PlayerPos;
    private NavMeshAgent AiEnemy;
    [SerializeField] private Transform[] HiddenPos = new Transform[6];
    [SerializeField] private bool[] HiddenPosIsPlayerIn = new bool[6];


    void Start()
    {

        AiEnemy = GetComponent<NavMeshAgent>();

    }

    // Update is called once per frame
    void Update()
    {

        if (AiEnemy.velocity == Vector3.zero)
        {
            
        AiEnemy.SetDestination(ChooseBestHiddenPos());



        }
    }

    Vector3 ChooseBestHiddenPos()
    {
        float ShorterDis=100; 
        float recentDis=100;
        Transform ShortestPath = null;
        int shorterIndex=0;
                // Debug.Log(ShorterDis);


        for (int i = 0; i < HiddenPos.Length; i++)
        {
           
recentDis = Vector3.Distance(transform.position, HiddenPos[i].position);


            if (recentDis < ShorterDis && HiddenPosIsPlayerIn[i] == false)
            {
                ShorterDis = recentDis;
                shorterIndex = i;
            }




        }
         HiddenPosIsPlayerIn[shorterIndex] = true;
        return HiddenPos[shorterIndex].position;



    }
}
