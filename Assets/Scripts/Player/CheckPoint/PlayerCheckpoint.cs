using MoreMountains.Feedbacks;
using UnityEngine;

public class PlayerCheckpoint : MonoBehaviour
{
    public Transform[] checkpoints;     // Assign in inspector
    private Transform lastCheckpoint;   // The most recent checkpoint
    public MMF_Player respawnFeedback;
    public GameObject HP1;
    public GameObject HP2;
    public GameObject HP3;
    int lives = 3;
    
bool enter1Time = false;
    void Start()
    {
        // Default to first checkpoint at start
        if (checkpoints.Length > 0)
            lastCheckpoint = checkpoints[0];
    }

    void Update()
    {
        // Check if player has fallen below Y = -20
        if (transform.position.y < -10f && transform.position.y> -10.50f)
        {
            Respawn();
            
            if (lives > 0)
            {
                lives--;
                if (lives == 2)
                {
                    HP3.SetActive(false);
                    return;
                }
                else if (lives == 1)
                {
                    HP2.SetActive(false);
                     return;
                }
                else if (lives == 0)
                {
                    HP1.SetActive(false);
                     return;
                    // Handle game over logic here if needed
                }
            }
        }
    }

    void Respawn()
    {
        Rigidbody rb = GetComponent<Rigidbody>();
         if (rb != null)
        {
            rb.linearVelocity = Vector3.zero; // Reset velocity to prevent continued fall
        }
        transform.position = lastCheckpoint.position;
        
        respawnFeedback?.PlayFeedbacks();
        
       
    }

    public void SetCheckpoint(Transform newCheckpoint)
    {
        lastCheckpoint = newCheckpoint;
    }
}
