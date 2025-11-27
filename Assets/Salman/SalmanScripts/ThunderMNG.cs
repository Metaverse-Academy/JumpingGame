using UnityEngine;

public class ThunderMNG : MonoBehaviour
{
[SerializeField] private Animator DircLight;
[SerializeField] private Animator Cloud;
float recentTime ;
float randomTime;
    void Start()
    {
        randomTime = Random.Range(10f,45f);
    }
  void Update()
    {
Debug.Log($"this is recent time{recentTime}");
Debug.Log($"this is random time{randomTime}");

recentTime += Time.deltaTime;
if (recentTime > randomTime)
        {
            recentTime = 0;
        randomTime = Random.Range(10f,45f);
DircLight.SetTrigger("Thunder");
Cloud.SetTrigger("Thunder");


        }



    }
}
