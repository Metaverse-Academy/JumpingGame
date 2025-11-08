using UnityEngine;

public class PlayerDetector : MonoBehaviour
{



    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {
            MokeyAi scripts = transform.GetComponentInParent<MokeyAi>();
            scripts.StartAttack();


        }



    }
    void OnTriggerExit(Collider other)
    {
         if (other.CompareTag("Player"))
        {
            MokeyAi scripts = transform.GetComponentInParent<MokeyAi>();
            scripts.StartIdle();


        }
    }
}
