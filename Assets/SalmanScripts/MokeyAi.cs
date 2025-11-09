using System.Collections;
using System.Linq;
using MoreMountains.Feedbacks;
using Unity.InferenceEngine.Tokenization;
using UnityEngine;
using UnityEngine.AI;
public class MokeyAi : MonoBehaviour
{

    private Animator animator;
    enum EnemyStates { Idle, attack };
   [SerializeField] EnemyStates States;
    private NavMeshAgent AiEnemy;
    [SerializeField] private Transform newPosToGo;
    [SerializeField] private GameObject Player;
    [SerializeField] private MMF_Player hitFeedback;
    RaycastHit Hit;
    private string RecentTag;

    [SerializeField] private BoxCollider boxCollider;
    private Vector3[] CornerPos = new Vector3[4];

    Vector3 Up;
    Vector3 Right;
    Vector3 Left;
    Vector3 Down;

    GameObject myOP;

    [SerializeField]int ForceOfThePush;


    //for states
    bool IdleOneTime = false;
    bool attackOneTime = false;


    //AI Thinking
    bool DidYouWantToSeePlayer;
    bool iWantToStopAttacking = true;
    int MyRecentPos=-1;

    //test
    float recentTime;
    bool Iswalking=false;

    void Start()
    {
        animator = GetComponent<Animator>();
        AiEnemy = GetComponent<NavMeshAgent>();
        StartIdle();
    }

    // Update is called once per frame
    void Update()
    {
        Debug.Log(Iswalking);
        animator.SetBool("IsWalking", Iswalking);



        //   Debug.Log($"I am {gameObject.name} my pos is = {MyRecentPos}");
        if (Physics.Raycast(transform.position, transform.TransformDirection(Vector3.forward), out Hit, 50))
        {
            RecentTag = Hit.collider.gameObject.tag;
        }
        else
        {
            RecentTag = null;
        }
        Debug.DrawRay(transform.position, transform.TransformDirection(Vector3.forward) * 50, Color.red);


        if (DidYouWantToSeePlayer == true)
        {

            transform.LookAt(Player.transform);
        }





        switch (States)
        {

            case EnemyStates.Idle:

                if (IdleOneTime)
                {


                    recentTime += Time.deltaTime;
                     
                                if (recentTime > 6)
                    {

                        recentTime = 0;
                        Iswalking=true;
                        animator.SetTrigger("StartWalk");
                        AiEnemy.SetDestination(findPath());
                       
                                            
                                }
 if (AiEnemy.isStopped)
                        {
                            
                                                    Iswalking=false;

                        }

                }




                break;


            case EnemyStates.attack:

                if (attackOneTime)
                {
     Iswalking=true;

                    Vector3 targetPos = Player.transform.position;
                    targetPos.y = transform.position.y;
                    transform.LookAt(targetPos);
                    AiEnemy.SetDestination(Player.transform.position);
            





                }




                break;


       

        }



    }
    public void StartIdle()
    {
        IdleOneTime = true;
        States = EnemyStates.Idle;
             Iswalking=false;

        Debug.Log("start idle");

    }

      public void StartAttack()
    {
        attackOneTime = true;
        IdleOneTime = false;
     Iswalking=true;
        animator.SetTrigger("StartWalk");




        States = EnemyStates.attack;
        Debug.Log("start Attack");

    }

    Vector3 findPath()
    {
        Bounds bounds = boxCollider.bounds;

        float minX = bounds.min.x;
        float maxX = bounds.max.x;
        float minZ = bounds.min.z;
        float maxZ = bounds.max.z;
        float y = bounds.max.y;

        float randX = Random.Range(minX, maxX);
        float randZ = Random.Range(minZ, maxZ);

        return new Vector3(randX, y, randZ);
    }

    void OnTriggerEnter(Collider other)
    {

        if (other.CompareTag("Player"))
        {
            
            Rigidbody PlayerRB = other.gameObject.GetComponent<Rigidbody>();
            StartCoroutine(other.gameObject.GetComponent<PlayerMovement>().setPushed());
                        // PlayerRB.AddForce((Player.transform.position - transform.position) * ForceOfThePush, ForceMode.Impulse);
            Debug.Log("adding new force");
Vector3 dir = (Player.transform.position - transform.position).normalized;
PlayerRB.AddForce(dir * ForceOfThePush, ForceMode.Impulse);


        }



    }

   public IEnumerator Death()
    {


                    Debug.Log("death");

        Rigidbody PlayerRB = Player.gameObject.GetComponent<Rigidbody>();
        PlayerRB.AddForce((Player.transform.position - transform.position) * 15, ForceMode.Impulse);
        hitFeedback.PlayFeedbacks();
        animator.SetTrigger("Death");
        yield return new WaitForSeconds(2.10f);

        Destroy(gameObject);

    }
}
