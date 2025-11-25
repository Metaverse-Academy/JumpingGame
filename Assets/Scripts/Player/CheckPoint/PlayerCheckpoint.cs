using System.Collections;
using MoreMountains.Feedbacks;
using UnityEngine;

public class PlayerCheckpoint : MonoBehaviour
{
   
    private Vector3 lastCheckpoint;
    public MMF_Player respawnFeedback;
    public GameObject HP1;
    public GameObject HP2;
    public GameObject HP3;
    int lives = 3;
    public static PlayerCheckpoint instance;
    public bool isRespawning = false;
    public float respawnCooldown = 0.5f;
    [SerializeField] private Vector3 initialPosition;
    [SerializeField] private Quaternion initialRotation;

     Rigidbody rb;
    void Awake()
    {
        instance = this;
       
        lastCheckpoint = initialPosition;
          rb = GetComponent<Rigidbody>();
    }
    void Start()
    {
        
        UpdateHP();
    }

    void Update()
    {
        if (!isRespawning && transform.position.y < -10f)
        {
            StartCoroutine(HandleRespawn());
        }
    }

    private IEnumerator HandleRespawn()
    {
        isRespawning = true;

        if (lives > 0)
        {
            lives--;
            UpdateHP();
        }

       Debug.Log("Respawning at last checkpoint"+ lastCheckpoint);
         Vector3 targetPos = lastCheckpoint != Vector3.zero ? lastCheckpoint : initialPosition;
        // Quaternion targetRot = lastCheckpoint != null ? lastCheckpoint : initialRotation;
         if (lastCheckpoint != Vector3.zero)
        {
            rb.position = targetPos;
            // rb.rotation = targetRot;
            
             rb.linearVelocity = Vector3.zero;
        rb.angularVelocity = Vector3.zero;
        respawnFeedback?.PlayFeedbacks();
        }

        yield return new WaitForSeconds(respawnCooldown);
        isRespawning = false;
    }

    // void Respawn()
    // {
    //     Debug.Log("Respawning at last checkpoint"+ lastCheckpoint.position);
    //     Rigidbody rb = GetComponent<Rigidbody>();
    //      Vector3 targetPos = lastCheckpoint != null ? lastCheckpoint.position : initialPosition;
    //     Quaternion targetRot = lastCheckpoint != null ? lastCheckpoint.rotation : initialRotation;
    //      if (lastCheckpoint != null)
    //     {
    //         rb.position = targetPos;
    //         rb.rotation = targetRot;
            
    //          rb.linearVelocity = Vector3.zero;
    //     rb.angularVelocity = Vector3.zero;
    //     respawnFeedback?.PlayFeedbacks();
    //     }
       
    // // else
    // // {
    // //     if (lastCheckpoint != null)
    // //     {
    // //         transform.position = lastCheckpoint.position;
    // //         transform.rotation = Quaternion.identity;
    // //     }

        
    // // }
    // }

    private void UpdateHP()
    {
        lives = Mathf.Clamp(lives, 0, 3);
        if (HP1 != null) HP1.SetActive(lives >= 1);
        if (HP2 != null) HP2.SetActive(lives >= 2);
        if (HP3 != null) HP3.SetActive(lives >= 3);
    }

    public void SetCheckpoint(Transform newCheckpoint)
    {
        lastCheckpoint = newCheckpoint.position;
    }
}
