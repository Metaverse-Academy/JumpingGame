using System;
using System.Collections;
using Unity.Cinemachine;
using UnityEngine;
using UnityEngine.InputSystem;
using MoreMountains.Feedbacks;

public class WallRunning : MonoBehaviour
{
    // =========================
    //  Public (Inspector) Data
    // =========================

    // Layers
    public LayerMask wallLayer;
    public LayerMask groundLayer;

    // References
    public Animator blackFrameUp;
    public Animator blackFrameDown;

    public PlayerInput playerInput;
    public Transform orientation;
    public PlayerMovement playerMovement;
    public Rigidbody rb;
    public Transform camTransform;

    public CinemachineCamera wallRunCamera;
    public MMF_Player wallRunStartFeedback;
    public CinemachineImpulseSource cameraImpulse;
    public GameObject trailEffect;

    // Wall tags
    public string leftWallTag = "WallLeft";
    public string rightWallTag = "WallRight";

    // =========================
    //  Wall Run Settings
    // =========================
    public float wallCheckDistance = 0.8f;
    public float wallRunTargetSpeed = 12f;
    public float wallRunLerpSpeed = 8f;
    public float maxDownwardWallSpeed = -5f;

    public float wallJumpForce = 10f;

    public float cameraTiltAmount = 10f;
    public float cameraTiltLerpSpeed = 10f;

    // Cooldown (if you want to use it later)
    public float wallRunningCooldown = 0.4f;

    // =========================
    //  Runtime State
    // =========================
    public bool isWallRunning;
    public WallData currentWallData;

    private bool leftWall;
    private bool rightWall;

    private float wallRunningCooldownTimer;
    private bool startRunOnce = false;

    private Collider currentWallCollider;
    private Vector3 currentWallNormal;

    // =========================
    //  Unity Methods
    // =========================

    private void Start()
    {
        if (rb == null) rb = GetComponent<Rigidbody>();
        if (playerMovement == null) playerMovement = GetComponent<PlayerMovement>();
        if (playerInput == null) playerInput = GetComponent<PlayerInput>();
    }

    private void Update()
    {
        CheckForWall();

        if (wallRunningCooldownTimer > 0f)
            wallRunningCooldownTimer -= Time.deltaTime;
    }

    private void FixedUpdate()
    {
        if (leftWall || rightWall)
        {
            if (!isWallRunning)
                StartWallRun();

            HandleWallRunMovement();
        }
        else
        {
            if (isWallRunning)
                StopWallRun();
        }
    }

    private void OnDrawGizmosSelected()
    {
        Gizmos.DrawWireSphere(transform.position, wallCheckDistance);
    }

    // =========================
    //  Wall Run Core
    // =========================

    private void StartWallRun()
    {
        if (!startRunOnce)
        {
            startRunOnce = true;
            playerMovement.ISPlayerJumpFromWall = true;
        }

        isWallRunning = true;
        rb.useGravity = false;

        if (trailEffect != null)
            trailEffect.SetActive(true);

        if (wallRunStartFeedback != null)
            wallRunStartFeedback.PlayFeedbacks();

        // Optional: don't slam downward on latch
        Vector3 vel = rb.linearVelocity;
        if (vel.y < 0f)
        {
            vel.y = 0f;
            rb.linearVelocity = vel;
        }

        AudioMNG.instance.WallRun(1);
    }

    private void StopWallRun()
    {
        isWallRunning = false;
        rb.useGravity = true;

        if (trailEffect != null)
            trailEffect.SetActive(false);

        AudioMNG.instance.WallRun(0);

        StartCoroutine(CameraDutchReset());
    }

    private IEnumerator CameraDutchReset()
    {
        yield return new WaitForSeconds(0.2f);
        if (wallRunCamera != null)
            wallRunCamera.Lens.Dutch = 0f;
    }

    private void HandleWallRunMovement()
    {
        // ---- Camera Tilt ----
        if (wallRunCamera != null)
        {
            float targetTilt = 0f;
            if (leftWall) targetTilt = -cameraTiltAmount;
            else if (rightWall) targetTilt = cameraTiltAmount;

            wallRunCamera.Lens.Dutch = Mathf.Lerp(
                wallRunCamera.Lens.Dutch,
                targetTilt,
                cameraTiltLerpSpeed * Time.fixedDeltaTime
            );
        }

        // ---- Wall Direction ----
        // Use world +Z (global forward) always so wall run moves along world Z regardless of player rotation
        Vector3 wallForward = Vector3.forward;

        // ---- Velocity Lerp (no AddForce for run) ----
        Vector3 currentVel = rb.linearVelocity;

        // Build horizontal-only vectors so Y is not changed
        Vector3 currentHoriz = new Vector3(currentVel.x, 0f, currentVel.z);
        Vector3 targetHoriz = wallForward * wallRunTargetSpeed;

        // Lerp only on horizontal components
        Vector3 lerpedHoriz = Vector3.Lerp(
            currentHoriz,
            targetHoriz,
            wallRunLerpSpeed * Time.fixedDeltaTime
        );

        // Preserve vertical level: lock vertical velocity to zero while wall running
        rb.linearVelocity = new Vector3(lerpedHoriz.x, 0f, lerpedHoriz.z);
    }

    // =========================
    //  Wall Detection
    // =========================

    private void CheckForWall()
    {
        leftWall = false;
        rightWall = false;
        currentWallCollider = null;
        currentWallNormal = Vector3.zero;
        currentWallData = null;

        Collider[] hits = Physics.OverlapSphere(transform.position, wallCheckDistance, wallLayer);

        foreach (Collider col in hits)
        {
            if (col.CompareTag(rightWallTag))
            {
                rightWall = true;
                leftWall = false;
                currentWallCollider = col;
                break;
            }
            else if (col.CompareTag(leftWallTag))
            {
                leftWall = true;
                rightWall = false;
                currentWallCollider = col;
                break;
            }
        }

        if (currentWallCollider != null)
        {
            Vector3 closestPoint = currentWallCollider.ClosestPoint(transform.position);
            currentWallNormal = (transform.position - closestPoint).normalized;

            currentWallData = currentWallCollider.GetComponent<WallData>();
        }
    }

    // =========================
    //  Wall Jump
    // =========================

    public void OnWallJump(InputAction.CallbackContext context)
    {
        if (!context.started) return;
        if (!isWallRunning) return;
        if (currentWallData == null) return;

        Vector3 jumpDirection;

        if (currentWallData.IsFinalWall)
        {
            // Final wall: jump straight up (same idea as normal jump)
            jumpDirection = Vector3.up;
            Debug.Log("Final wall jump (Up)");
        }
        else
        {
            // Left wall: jump +X
            // Right wall: jump -X
            float xDir = leftWall ? 2f : -2f    ;

            // Slight upward component so it feels like a jump, not just a shove
            jumpDirection = new Vector3(xDir, 0.5f, 0f).normalized;
            Debug.Log("Side wall jump (X direction)");
        }

        playerMovement.ISPlayerJumpFromWall = true;

        // Clean up downward velocity before applying impulse
        Vector3 vel = rb.linearVelocity;
        if (vel.y < 0f) vel.y = 0f;
        rb.linearVelocity = vel;

        rb.AddForce(jumpDirection * wallJumpForce, ForceMode.Impulse);

        if (currentWallData.IsFinalWall)
            Invoke(nameof(ResetFinalWallState), 0.3f);

        StopWallRun();
    }

    private void ResetFinalWallState()
    {
        Debug.Log("Reset final wall state");
        playerMovement.ISPlayerJumpFromWall = false;
    }
}
