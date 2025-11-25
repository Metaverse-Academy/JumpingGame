using UnityEngine;
using System.Collections;

public class MovingPlatform : MonoBehaviour
{
    [Header("Points")]
    public Transform pointA;   // Starting point
    public Transform pointB;   // Ending point

    [Header("Settings")]
    public float speed = 2f;
    public float waitTime = 0.5f;

    private Vector3 target;
    private bool waiting;

    private void Start()
    {
        target = pointB.position;
    }

    private void Update()
    {
        if (waiting) return;

        // Move platform
        transform.position = Vector3.MoveTowards(
            transform.position,
            target,
            speed * Time.deltaTime
        );

        // If reached the target, switch
        if (Vector3.Distance(transform.position, target) < 0.05f)
            StartCoroutine(SwitchTarget());
    }

    private IEnumerator SwitchTarget()
    {
        waiting = true;
        yield return new WaitForSeconds(waitTime);

        target = (target == pointA.position) ? pointB.position : pointA.position;
        waiting = false;
    }

    // Make player stick to platform
    private void OnCollisionEnter(Collision other)
    {
        if (other.collider.CompareTag("Player"))
        {
            other.transform.SetParent(transform);
        }
    }

    private void OnCollisionExit(Collision other)
    {
        if (other.collider.CompareTag("Player"))
        {
            other.transform.SetParent(null);
        }
    }
}
