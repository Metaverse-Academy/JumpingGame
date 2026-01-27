using UnityEngine;

public class CheckpointTrigger : MonoBehaviour
{
        [SerializeField] private bool setAsDefaultOnAwake = false;

    void Awake()
    {
        if (!setAsDefaultOnAwake) return;
        if (PlayerCheckpoint.instance == null) return;
        PlayerCheckpoint.instance.SetCheckpoint(transform);
    }
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
