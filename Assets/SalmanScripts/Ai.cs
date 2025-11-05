using Unity.VisualScripting;
using UnityEngine;
using UnityEngine.AI;

public class Ai : MonoBehaviour
{

    [SerializeField] GameObject BulletPrefab;
    enum EnemyStates {Run,attack,Hidden,Look};
   [SerializeField] EnemyStates States;
    private NavMeshAgent AiEnemy;
    [SerializeField] private Transform[] HiddenPos = new Transform[6];
    [SerializeField] private bool[] HiddenPosIsPlayerIn = new bool[6];
    [SerializeField] private GameObject Player;
    RaycastHit Hit;

    float TimeForBullet = 0;

    
    bool StartThink=true;

    void Start()
    {

        AiEnemy = GetComponent<NavMeshAgent>();
    }

    // Update is called once per frame
    void Update()
    {
        Physics.Raycast(transform.position,transform.TransformDirection(Vector3.forward),out Hit,4);
            Debug.DrawRay(transform.position, transform.TransformDirection(Vector3.forward) *50, Color.red); 


        switch (States)
        {

            case EnemyStates.Run:

                if (AiEnemy.velocity == Vector3.zero )
                                    
                        {
                                
                            AiEnemy.SetDestination(ChooseBestHiddenPos());
                            States = EnemyStates.Hidden;

                                        
                        }




                break;

            case EnemyStates.attack:

                // Debug.Log(TimeForBullet);
                transform.LookAt(Player.transform);

               TimeForBullet += Time.deltaTime;
                if (TimeForBullet > 1)
                {

                            TimeForBullet = 0;
                            Instantiate(BulletPrefab, gameObject.transform.position,gameObject.transform.rotation);
                        }


                break;


            case EnemyStates.Hidden:

                if (AiEnemy.velocity == Vector3.zero)
                {
                    States = EnemyStates.attack;
                }





                break;


            case EnemyStates.Look:




                break;



        }


        
    }

    Vector3 ChooseBestHiddenPos()
    {
        //dis from ai to hidden pos
        float ShorterDis = 100;
        float recentDis = 100;

        //longest pos from player to hidden pos
        float LongestDisFromPlayerToPos = 0;
        float recentDisFromPlayerToHiddenPos = 0;



        Transform PlayerPos = Player.transform;
        int shorterIndex = 8;

        

        for (int i = 0; i < HiddenPos.Length; i++)
        {

            if (HiddenPosIsPlayerIn[i] == false)
            {
                recentDis = Vector3.Distance(transform.position, HiddenPos[i].position);
                recentDisFromPlayerToHiddenPos = Vector3.Distance(PlayerPos.position, HiddenPos[i].position);

                if (recentDis < ShorterDis   )
                {

                    if (recentDisFromPlayerToHiddenPos > LongestDisFromPlayerToPos) { 
                    LongestDisFromPlayerToPos = recentDisFromPlayerToHiddenPos;
                    ShorterDis = recentDis;
                    shorterIndex = i;
                    }
                }
            }



        }



        resetTheIsAiHiddenBool(shorterIndex);

        return HiddenPos[shorterIndex].position;



    }
    void makeBoolTrue()
    {
        StartThink = true;

    }


    void resetTheIsAiHiddenBool(int j)
    {
        for (int i = 0; i < HiddenPosIsPlayerIn.Length; i++)
        {

            HiddenPosIsPlayerIn[i] = false;


        }

        HiddenPosIsPlayerIn[j] = true;


    }
}
