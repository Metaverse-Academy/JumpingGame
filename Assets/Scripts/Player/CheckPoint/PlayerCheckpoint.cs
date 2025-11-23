using System.Collections;
using MoreMountains.Feedbacks;
using UnityEngine;

public class PlayerCheckpoint : MonoBehaviour
{
    public Transform[] checkpoints;
    private Transform lastCheckpoint;
    public MMF_Player respawnFeedback;
    public GameObject HP1;
    public GameObject HP2;
    public GameObject HP3;
    int lives = 3;
    public static PlayerCheckpoint instance;
    public bool isRespawning = false;
    public float respawnCooldown = 0.5f;

    void Start()
    {
        instance = this;
        if (checkpoints.Length > 0)
            lastCheckpoint = checkpoints[0];

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

        Respawn();

        yield return new WaitForSeconds(respawnCooldown);
        isRespawning = false;
    }

    void Respawn()
    {
        Debug.Log("Respawning at last checkpoint"+ lastCheckpoint.position);
        Rigidbody rb = GetComponent<Rigidbody>();
         if (lastCheckpoint != null)
        {
            rb.position = lastCheckpoint.position;
            rb.rotation = Quaternion.identity;
            
             rb.linearVelocity = Vector3.zero;
        rb.angularVelocity = Vector3.zero;
        }
       
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
    }

    public void SetCheckpoint(Transform newCheckpoint)
    {
        lastCheckpoint = newCheckpoint;
    }
}
