using UnityEngine;

public class PlatformTrigger : MonoBehaviour
{
    [Header("Trigger Settings")]
    public bool triggerOnce = true;
    private bool hasTriggered = false;

    [Header("Platforms to Activate")]
    public GameObject[] activateThese;

    [Header("Platforms to Deactivate")]
    public GameObject[] deactivateThese;

    [Header("Optional Effects")]
    public ParticleSystem activateParticles;
    public ParticleSystem deactivateParticles;
    public AudioSource activateSound;
    public AudioSource deactivateSound;

    private void OnCollisionEnter(Collision collision)
    {
        if (hasTriggered && triggerOnce) return;

        if (collision.collider.CompareTag("Player"))
        {
            Trigger();
        }
    }

    private void Trigger()
    {
        // Mark as triggered so it cannot repeat
        hasTriggered = true;

        // --- Activate assigned platforms ---
        foreach (GameObject obj in activateThese)
        {
            if (obj != null) obj.SetActive(true);
        }

        // Play effect if exists
        if (activateParticles != null)
            activateParticles.Play();

        if (activateSound != null)
            activateSound.Play();

        // --- Deactivate assigned platforms ---
        foreach (GameObject obj in deactivateThese)
        {
            if (obj != null) obj.SetActive(false);
        }

        // Play effect if exists
        if (deactivateParticles != null)
            deactivateParticles.Play();

        if (deactivateSound != null)
            deactivateSound.Play();
    }
}
