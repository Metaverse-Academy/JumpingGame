using UnityEngine;

public class CheckpointTrigger : MonoBehaviour
{
    private void OnTriggerEnter(Collider other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
            PlayerCheckpoint playerCheckpoint = other.gameObject.GetComponent<PlayerCheckpoint>();
            if (playerCheckpoint != null)
            {
                Debug.Log("Checkpoint reached!");
                playerCheckpoint.SetCheckpoint(transform);
            }
        }
    }
    
}
