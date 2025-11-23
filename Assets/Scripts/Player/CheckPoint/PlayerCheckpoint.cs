using System.Collections;
using MoreMountains.Feedbacks;
using UnityEngine;

public class PlayerCheckpoint : MonoBehaviour
{
    public Transform[] checkpoints;
    private Transform lastCheckpoint;
    public MMF_Player respawnFeedback;
<<<<<<< Updated upstream
=======
    public GameObject HP1;
    public GameObject HP2;
    public GameObject HP3;
    int lives = 3;
    public static PlayerCheckpoint instance;
    public bool isRespawning = false;
    public float respawnCooldown = 0.5f;
>>>>>>> Stashed changes

    void Start()
    {
        instance = this;
        if (checkpoints.Length > 0)
            lastCheckpoint = checkpoints[0];

        UpdateHP();
    }

    void Update()
    {
<<<<<<< Updated upstream
        // Check if player has fallen below Y = -20
        if (transform.position.y < -20f)
        {
            Respawn();
=======
        if (!isRespawning && transform.position.y < -10f)
        {
            StartCoroutine(HandleRespawn());
>>>>>>> Stashed changes
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

        Respawn();

        yield return new WaitForSeconds(respawnCooldown);
        isRespawning = false;
    }

    void Respawn()
    {
<<<<<<< Updated upstream
        transform.position = lastCheckpoint.position;
        Rigidbody rb = GetComponent<Rigidbody>();
        respawnFeedback?.PlayFeedbacks();
        
        if (rb != null)
=======
        Debug.Log("Respawning at last checkpoint"+ lastCheckpoint.position);
        Rigidbody rb = GetComponent<Rigidbody>();
         if (lastCheckpoint != null)
>>>>>>> Stashed changes
        {
            rb.position = lastCheckpoint.position;
            rb.rotation = Quaternion.identity;
            
             rb.linearVelocity = Vector3.zero;
        rb.angularVelocity = Vector3.zero;
        }
<<<<<<< Updated upstream
=======
       
    else
    {
        if (lastCheckpoint != null)
        {
            transform.position = lastCheckpoint.position;
            transform.rotation = Quaternion.identity;
        }

        respawnFeedback?.PlayFeedbacks();
    }
    }

    private void UpdateHP()
    {
        lives = Mathf.Clamp(lives, 0, 3);
        if (HP1 != null) HP1.SetActive(lives >= 1);
        if (HP2 != null) HP2.SetActive(lives >= 2);
        if (HP3 != null) HP3.SetActive(lives >= 3);
>>>>>>> Stashed changes
    }

    public void SetCheckpoint(Transform newCheckpoint)
    {
        lastCheckpoint = newCheckpoint;
    }
}
