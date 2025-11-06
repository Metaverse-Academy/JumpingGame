using System.Collections;
using System.Linq;
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
    private string RecentTag;

    [SerializeField] private Transform LeftPoint;
    [SerializeField] private Transform rightPoint;

    float TimeForBullet = 0;

    
    bool StartThink=true;



    //for states
    bool RunOneTime = false;
    bool LookOneTime = false;
    bool OnOneTime = false;
    bool AttackOneTime = false;
    

    //AI Thinking
    bool DidYouWantToSeePlayer;
    bool iWantToStopAttacking =true;



    void Start()
    {

        AiEnemy = GetComponent<NavMeshAgent>();
    }

    // Update is called once per frame
    void Update()
    {
        if (Physics.Raycast(transform.position, transform.TransformDirection(Vector3.forward), out Hit, 50))
        {
            RecentTag = Hit.collider.gameObject.tag;
        }
        else
        {
            RecentTag = null;
        }
        Debug.DrawRay(transform.position, transform.TransformDirection(Vector3.forward) * 50, Color.red);

        Debug.Log(RecentTag);

        if (DidYouWantToSeePlayer == true)
        {

            transform.LookAt(Player.transform);
        }

        switch (States)
        {

            case EnemyStates.Run:


                if (RunOneTime == false)
                {
                    RunOneTime = true;
                    AiEnemy.SetDestination(ChooseBestHiddenPos());
                    Invoke("GoToHiddenState", 2f);
                }




                break;

            case EnemyStates.attack:


                if (AttackOneTime == false) { }
                TimeForBullet += Time.deltaTime;
                if (TimeForBullet > 0.3)
                {

                    TimeForBullet = 0;
                    Instantiate(BulletPrefab, gameObject.transform.position, gameObject.transform.rotation);
                }
                if (iWantToStopAttacking == true)
                {
                    iWantToStopAttacking = false;
                    StartCoroutine(StopFight());
                }

                break;


            case EnemyStates.Hidden:

                if (AiEnemy.velocity == Vector3.zero)
                {
                    StartToLook();
                }





                break;


            case EnemyStates.Look:

                DidYouWantToSeePlayer = true;

                if (LookOneTime == false)
                {
                    LookOneTime = true;
                    int RightOrLeft = Random.Range(0, 2);



                    if (RightOrLeft == 0)
                    {
                        OnOneTime = true;

                        StartCoroutine(TakeALook(1));

                    }
                    else if (RightOrLeft == 1)
                    {
                        OnOneTime = true;

                        StartCoroutine(TakeALook(2));

                    }
                }




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

                if (   recentDis < ShorterDis
)
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
    void GoToHiddenState()
    {
        States = EnemyStates.Hidden;
        Debug.Log("it is work ");
    }



    IEnumerator TakeALook(int i)
    {
        Debug.Log("Hahaha.......");





        yield return new WaitForSeconds(Random.Range(0, 6));


        if (i == 1)
        {
            AiEnemy.SetDestination(LeftPoint.position);


        }
        else if (i == 2)
        {
            AiEnemy.SetDestination(rightPoint.position);


        }

        yield return new WaitForSeconds(Random.Range(1, 3));

        if (RecentTag == "Player")
        {
            States = EnemyStates.attack;

        }
        else
        {
            StartToRun();
        }

    }
    IEnumerator StopFight()
    {


        yield return new WaitForSeconds(Random.Range(1, 5));
        StartToRun();
        iWantToStopAttacking = true;

    }
    void StartToRun()
    {
        DidYouWantToSeePlayer = false;

        RunOneTime = false;

        States = EnemyStates.Run;


    }
    void StartToLook()
    {
        LookOneTime = false;

        States = EnemyStates.Look;


    }

    void OnTriggerEnter(Collider other)
    {

        if (other.CompareTag("Player"))
        {

            Rigidbody rb = other.gameObject.GetComponent<Rigidbody>();
            rb.AddForce((transform.position-other.gameObject.transform.position)*30,ForceMode.Impulse);
            Destroy(gameObject);

        }


    }
}
