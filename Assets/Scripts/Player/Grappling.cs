using System;
using UnityEngine;
using UnityEngine.InputSystem;
using Unity.Cinemachine;
using System.Collections;

public class Grappling : MonoBehaviour
{
    private LineRenderer lr;
    private Vector3 grapplePoint;
    public LayerMask whatIsGrappleable;
    public Transform gunTip, player;
    [SerializeField] private float maxDistance = 12f;
    public bool zeroVelocityOnStart = true;
    private SpringJoint joint;
    public PlayerInput playerInput;
    [SerializeField] public float jointSpring = 4.5f;
    [SerializeField] public float jointDamper = 7f;
    [SerializeField] public float jointMassScale = 4.5f;
    public CinemachineCamera defaultCamera;
    public static Grappling instance;
    public bool isGrappling;
    public AudioSource audioSource;

    [Header("References")]
    public Transform cameraTransform;

    private Rigidbody playerRb;
    float moveTarget = 0f;
    float moveSmooth = 0f;
    float moveSmoothVel = 0f;
    [SerializeField] public float moveForce = 12f;
    [SerializeField] public float inputSmoothTime = 0.08f;

    [Header("Swing Settings")]
    public float swingForce = 10f; // 10 for good initial momentum as you asked
    public bool autoSwingToTarget = true;

    [Header("Auto Release Settings")]
    public float swingTime = 1.2f;
    public float launchBoost = 8f;

    void Awake()
    {
        lr = GetComponent<LineRenderer>();
        playerInput = GetComponent<PlayerInput>();
        if (player != null)
            playerRb = player.GetComponent<Rigidbody>();
    }

    void Start()
    {
        StartCoroutine(IntitializeGrapple());
        instance = this;
    }

    private IEnumerator IntitializeGrapple()
    {
        lr.enabled = false;
        joint = player.gameObject.AddComponent<SpringJoint>();
        yield return new WaitForSeconds(0.1f);
        if (joint) Destroy(joint);
    }

    public void OnGrapple(InputAction.CallbackContext context)
    {
        if (context.performed && !isGrappling)
        {
            StartGrapple();
        }
        else if (context.canceled)
        {
            isGrappling = false;
            StopGrapple();
        }
    }

    public void OnMove(InputAction.CallbackContext ctx)
    {
        // W = positive (forward), S = negative (backward)
        Vector2 v = ctx.ReadValue<Vector2>();
        moveTarget = v.y;
    }

    private void StopGrapple()
    {
        AudioMNG.instance.RopeSWing(0);
        isGrappling = false;
        lr.positionCount = 0;
        defaultCamera.Lens.FieldOfView = 90f;
        if (joint) Destroy(joint);
        moveTarget = 0f;
        moveSmooth = 0f;
        moveSmoothVel = 0f;
    }

    private void StartGrapple()
    {
        if (!lr.enabled)
            lr.enabled = true;

        StartCoroutine(CheckGrappling());
    }

    IEnumerator CheckGrappling()
    {
        Collider[] hits = Physics.OverlapSphere(player.position, maxDistance, whatIsGrappleable, QueryTriggerInteraction.Ignore);
        if (hits == null || hits.Length == 0)
        {
            Debug.Log("No grapple target nearby on the selected layer.");
            yield break;
        }

        Collider box = hits[0];
        grapplePoint = box.ClosestPoint(player.position);
        AudioMNG.instance.RopeSWing(1);
        AudioMNG.instance.PlaySounds(1);

        joint = player.gameObject.AddComponent<SpringJoint>();
        joint.autoConfigureConnectedAnchor = false;
        joint.connectedAnchor = grapplePoint;
        yield return new WaitForFixedUpdate();

        float distanceFromPoint = Vector3.Distance(player.position, grapplePoint);
        float shortenFactor = 0.8f; // just initial setup, not driven by input
        joint.maxDistance = distanceFromPoint * shortenFactor;
        joint.minDistance = distanceFromPoint * shortenFactor * 0.5f;

        joint.spring = jointSpring;
        joint.damper = jointDamper;
        joint.massScale = jointMassScale;
        joint.enableCollision = true;

        lr.positionCount = 2;
        isGrappling = true;

        moveTarget = 0f;
        moveSmooth = 0f;
        moveSmoothVel = 0f;

        if (zeroVelocityOnStart && playerRb != null)
        {
            playerRb.linearVelocity = Vector3.zero;
            playerRb.angularVelocity = Vector3.zero;
        }

        // Initial camera-based swing impulse so it doesn't feel "stopped"
        if (autoSwingToTarget && cameraTransform != null && playerRb != null)
        {
            Vector3 grappleDir = (grapplePoint - player.position).normalized;
            Vector3 cameraDir = cameraTransform.forward;

            // Direction tangent to the rope but aligned with where the camera is looking
            Vector3 swingDir = Vector3.Cross(grappleDir, Vector3.Cross(cameraDir, grappleDir)).normalized;

            // Give an initial velocity of magnitude ~10 in that direction
            playerRb.linearVelocity += swingDir * swingForce;

            StartCoroutine(AutoReleaseGrapple());
        }

        if (audioSource) audioSource.Play();
    }

    void LateUpdate()
    {
        DrawRope();
    }

    void DrawRope()
    {
        if (!joint) return;
        lr.SetPosition(0, gunTip.position);
        lr.SetPosition(1, grapplePoint);
    }

    void FixedUpdate()
    {
        if (playerRb == null)
            return;

        // Smoothly move input towards target (W/S)
        moveSmooth = Mathf.SmoothDamp(moveSmooth, moveTarget, ref moveSmoothVel, inputSmoothTime);

        if (!isGrappling || joint == null)
            return;

        // --- Move along the arc using camera-based forward ---

        if (!autoSwingToTarget && Mathf.Abs(moveSmooth) > 0.01f)
        {
            // Direction of the rope (player to grapple)
            Vector3 ropeDir = (grapplePoint - player.position).normalized;

            // Camera forward/right
            Vector3 aimForward = cameraTransform != null ? cameraTransform.forward : player.forward;
            Vector3 aimRight   = cameraTransform != null ? cameraTransform.right   : player.right;

            // Project camera forward onto plane perpendicular to rope => move along swing arc
            Vector3 forwardAlongArc = Vector3.ProjectOnPlane(aimForward, ropeDir).normalized;
            if (forwardAlongArc.sqrMagnitude < 0.001f)
            {
                // If looking directly along the rope, fall back to right direction
                forwardAlongArc = Vector3.ProjectOnPlane(aimRight, ropeDir).normalized;
            }

            // W (positive) pushes forwardAlongArc, S (negative) pushes opposite
            Vector3 force = forwardAlongArc * (moveSmooth * moveForce);
            playerRb.AddForceAtPosition(force, gunTip.position, ForceMode.Acceleration);

            // Small tangential damping to keep it stable
            Vector3 radialVel = Vector3.Project(playerRb.linearVelocity, ropeDir);
            Vector3 tangentialVel = playerRb.linearVelocity - radialVel;
            playerRb.AddForce(-tangentialVel * 0.12f, ForceMode.Acceleration);
        }
        else
        {
            // Light auto damping when no manual input or autoSwingToTarget is true
            Vector3 ropeDir = (grapplePoint - player.position).normalized;
            Vector3 radialVel = Vector3.Project(playerRb.linearVelocity, ropeDir);
            Vector3 tangentialVel = playerRb.linearVelocity - radialVel;
            playerRb.AddForce(-tangentialVel * 0.05f, ForceMode.Acceleration);
        }
    }

    private IEnumerator AutoReleaseGrapple()
    {
        yield return new WaitForSeconds(swingTime);

        if (!isGrappling || joint == null || playerRb == null)
            yield break;

        Vector3 exitVelocity = playerRb.linearVelocity;
        StopGrapple();

        // Launch in camera forward + keep swing velocity
        if (cameraTransform != null)
        {
            Vector3 forwardDir = cameraTransform.forward;
            playerRb.linearVelocity = exitVelocity + forwardDir * launchBoost;
        }
    }
}
