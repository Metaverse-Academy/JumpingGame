using UnityEngine;
using System.Collections;

public class CrumblingPlatform_Timed : MonoBehaviour
{
    [Header("Platform Settings")]
    public float delayBeforeShake = 1.5f;     // Time before shaking starts (player thinks it's safe)
    public float shakeDuration = 1f;          // How long it shakes before falling
    public float shakeIntensity = 0.05f;      // How strong the shake looks
    public float respawnTime = 3f;            // How long until it resets

    private Vector3 originalPosition;
    private Rigidbody rb;
    private bool isFalling = false;

    private void Start()
    {
        originalPosition = transform.position;
        rb = GetComponent<Rigidbody>();

        if (rb == null)
            rb = gameObject.AddComponent<Rigidbody>();

        rb.isKinematic = true;
        rb.useGravity = true;
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (!isFalling && collision.gameObject.CompareTag("Player"))
        {
            StartCoroutine(Crumble());
        }
    }

    private IEnumerator Crumble()
    {
        isFalling = true;

        // Wait before shaking starts — the "safe" moment
        yield return new WaitForSeconds(delayBeforeShake);

        // Start shaking for a short while
        float elapsed = 0f;
        while (elapsed < shakeDuration)
        {
            transform.position = originalPosition + Random.insideUnitSphere * shakeIntensity;
            elapsed += Time.deltaTime;
            yield return null;
        }

        // Reset position (avoid floating jitter)
        transform.position = originalPosition;

        // Let gravity make it fall
        rb.isKinematic = false;

        // Wait, then reset platform
        yield return new WaitForSeconds(respawnTime);

        rb.isKinematic = true;
        rb.linearVelocity = Vector3.zero;
        transform.position = originalPosition;
        isFalling = false;
    }
}
