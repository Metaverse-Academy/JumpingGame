using MoreMountains.Feedbacks;
using UnityEngine;

public class PlayerCheckpoint : MonoBehaviour
{
    public Transform[] checkpoints;     // Assign in inspector
    private Transform lastCheckpoint;   // The most recent checkpoint
    public MMF_Player respawnFeedback;

    void Start()
    {
        // Default to first checkpoint at start
        if (checkpoints.Length > 0)
            lastCheckpoint = checkpoints[0];
    }

    void Update()
    {
        // Check if player has fallen below Y = -20
        if (transform.position.y < -10f)
        {
            Respawn();
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
