using UnityEngine;

public class HeadDetect : MonoBehaviour
{


    void OnTriggerEnter(Collider other)
    {
        if (other.CompareTag("Player"))
        {                    Debug.Log("deathFromScripts");

            MokeyAi scripts = transform.GetComponentInParent<MokeyAi>();
            StartCoroutine(scripts.Death());

        }
    }

}
