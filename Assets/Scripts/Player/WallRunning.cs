using System;
using Unity.Cinemachine;
using UnityEngine;
using UnityEngine.InputSystem;
using System.Collections;
using MoreMountains.Feedbacks;

public class WallRunning : MonoBehaviour
{
    [Header("Layer Masks")]
    [SerializeField] private LayerMask wallLayer;
    [SerializeField] private LayerMask groundLayer;

    [Header("References")]
    [SerializeField] private Animator BlackFramUp;
    [SerializeField] private Animator BlackFramDown;

    [SerializeField] private PlayerInput playerInput;
    [SerializeField] private Transform orientation;
    [SerializeField] private PlayerMovement playerMovement;
    [SerializeField] private Rigidbody rb;
    [SerializeField] private Transform camTransform;

    [Header("Wall Running Settings")]
    [SerializeField] private float wallRunForce = 10f;
    [SerializeField] private float maxWallRunTime = 2f;
    private float wallRunTimer;

    [SerializeField] private float wallJumpForce = 40f;
    [SerializeField] private float wallRunningCooldown = 0.4f;
    private float wallRunningCooldownTimer;

    // 🔹 New: control speed & stickiness (only partly used in this simple version)
    [SerializeField] private float targetWallRunSpeed = 12f;
    [SerializeField] private float wallStickForce = 30f;
    [SerializeField] private float maxDownwardWallSpeed = -5f;

    [Header("Limits (optional, not all used here)")]
    [SerializeField] private float maxWallRunSpeed = 18f;
    [SerializeField] private float maxWallRunVerticalSpeed = 10f;

    [SerializeField] private CinemachineCamera WallRunCamera;
    public MMF_Player wallRunStartFeedback;
    public CinemachineImpulseSource cameraImpulse;

    [Header("Wall Check Settings")]
    [Tooltip("Radius around the player used to find walls (replaces raycast distance).")]
    [SerializeField] private float wallCheckDistance = 0.8f; // now used as radius

    [SerializeField] private float minJumpHeight = 1.5f;

    [Header("Wall Tags")]
    [SerializeField] private string leftWallTag = "WallLeft";
    [SerializeField] private string rightWallTag = "WallRight";

    private float mainCameraleftDutch = -10f;
    private float mainCameraRightDutch = 10f;

    private bool leftWall;
    private bool rightWall;

    public GameObject trailEffect;
    public bool isWallRunning;
    public WallData TheWallThePlayerRunOnIt;

    // i do this bool cus i want the StartWallRun Func run one time
    bool StartRunOnTime = false;

    // New: replaces RaycastHit
    private Collider currentWallCollider;
    private Vector3 currentWallNormal;

    private void Start()
    {
        rb = GetComponent<Rigidbody>();
        playerMovement = GetComponent<PlayerMovement>();
        playerInput = GetComponent<PlayerInput>();
    }

    private void Update()
    {
        // UI anims
        // BlackFramUp.SetBool("IsWallRun", playerMovement.ISPlayerJumpFromWall);
        // BlackFramDown.SetBool("IsWallRunning", playerMovement.ISPlayerJumpFromWall);

        // Adjust wall jump force based on wall data
        if (TheWallThePlayerRunOnIt)
        {
            if (TheWallThePlayerRunOnIt.IsFinalWall)
                wallJumpForce = 22f;
            else
                wallJumpForce = 38f;
        }

        CheckForWall();

        if (wallRunningCooldownTimer > 0f)
        {
            wallRunningCooldownTimer -= Time.deltaTime;
        }
    }

    private IEnumerator CameraDutchReset()
    {
        yield return new WaitForSeconds(0.2f);
        WallRunCamera.Lens.Dutch = 0f;
    }

    private void FixedUpdate()
    {
        if (leftWall || rightWall)
        {
            if (!isWallRunning)
            {
                StartWallRun();
            }

            WallRunningMovement();
        }
        else
        {
            if (isWallRunning)
            {
                StopWallRun();
            }
        }
    }

    private void StopWallRun()
    {
        AudioMNG.instance.WallRun(0);

        Debug.Log("stop running");

        isWallRunning = false;

        rb.useGravity = true;
        trailEffect.SetActive(false);

        StartCoroutine(CameraDutchReset());
    }

    private void WallRunningMovement()
{
    // Camera tilt + audio
    if (leftWall)
    {
        WallRunCamera.Lens.Dutch = Mathf.Lerp(
            WallRunCamera.Lens.Dutch,
            -mainCameraleftDutch,
            Time.fixedDeltaTime * 1f
        );
        AudioMNG.instance.WallRun(1);
    }
    else if (rightWall)
    {
        WallRunCamera.Lens.Dutch = Mathf.Lerp(
            WallRunCamera.Lens.Dutch,
            mainCameraRightDutch,
            Time.fixedDeltaTime * 1f
        );
        AudioMNG.instance.WallRun(1);
    }

    // --- Get wall normal (from your detection) ---
    Vector3 wallNormal = currentWallNormal;

    // Safety: if something went wrong, fall back to a side direction
    if (wallNormal == Vector3.zero)
    {
        wallNormal = rightWall ? orientation.right : -orientation.right;
    }

    // Direction along the wall (perpendicular to normal & up)
    Vector3 wallForward = Vector3.Cross(wallNormal, Vector3.up).normalized;

    // Make sure it's aligned with where the player looks
    if (Vector3.Dot(wallForward, orientation.forward) < 0f)
    {
        wallForward = -wallForward;
    }

    // --- SHAPE VELOCITY TO TARGET SPEED ---

    // Current velocity
    Vector3 vel = rb.linearVelocity;

    // Component going into the wall
    Vector3 velIntoWall = Vector3.Project(vel, -wallNormal);

    // Component sliding along the wall
    Vector3 velAlongWall = vel - velIntoWall;

    // Vertical velocity: clamp how fast we can fall while wallrunning
    float verticalVel = vel.y;
    if (verticalVel < maxDownwardWallSpeed)
    {
        verticalVel = maxDownwardWallSpeed;
    }

    // Ensure a minimum speed along the wall (e.g. 11.8)
    float currentSpeedAlongWall = velAlongWall.magnitude;
    float desiredSpeed = targetWallRunSpeed;   // set this to 11.8f in Inspector

    if (currentSpeedAlongWall < desiredSpeed)
    {
        velAlongWall = wallForward * desiredSpeed;
    }
    else
    {
        // Keep current speed but align with wall direction
        velAlongWall = wallForward * currentSpeedAlongWall;
    }

    // Apply combined velocity: along wall + vertical
    Vector3 newVel = new Vector3(velAlongWall.x, verticalVel, velAlongWall.z);
    rb.linearVelocity = newVel;

    // Push slightly into the wall to keep us attached
    rb.AddForce(-wallNormal * wallStickForce, ForceMode.Acceleration);
}

    private void StartWallRun()
    {
        if (!StartRunOnTime)
        {
            StartRunOnTime = true;
            playerMovement.ISPlayerJumpFromWall = true;
        }

        isWallRunning = true;
        wallRunTimer = maxWallRunTime;
        rb.useGravity = false;
        trailEffect.SetActive(true);
        wallRunStartFeedback.PlayFeedbacks();
        // cameraImpulse.GenerateImpulse();

        // Optional: don't let us slam downward on latch
        Vector3 vel = rb.linearVelocity;
        if (vel.y < 0f)
        {
            vel.y = 0f;
            rb.linearVelocity = vel;
        }
    }

    private bool AboveGround()
    {
        RaycastHit hit;
        if (Physics.Raycast(transform.position, Vector3.down, out hit, minJumpHeight, groundLayer))
        {
            return true;
        }
        return false;
    }

    // ============================================
    //  Tag-based wall check using OverlapSphere
    // ============================================
    private void CheckForWall()
    {
        leftWall = false;
        rightWall = false;
        currentWallCollider = null;
        currentWallNormal = Vector3.zero;
        TheWallThePlayerRunOnIt = null;

        // Use a sphere around the player instead of raycasts
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
            // Approximate wall normal using closest point
            Vector3 closestPoint = currentWallCollider.ClosestPoint(transform.position);
            currentWallNormal = (transform.position - closestPoint).normalized;

            TheWallThePlayerRunOnIt = currentWallCollider.GetComponent<WallData>();
            if (TheWallThePlayerRunOnIt != null)
            {
                Debug.Log(TheWallThePlayerRunOnIt.IsFinalWall);
            }
        }
    }

    // ==============================
    //  Wall Jump
    // ==============================
    public void OnWallJump(InputAction.CallbackContext context)
    {
        if (context.started && isWallRunning && TheWallThePlayerRunOnIt != null)
        {
            Vector3 wallNormal = currentWallNormal;

            // Safety: fallback normal
            if (wallNormal == Vector3.zero)
            {
                wallNormal = rightWall ? orientation.right : -orientation.right;
            }

            if (TheWallThePlayerRunOnIt.IsFinalWall)
            {
                // Final wall: jump up & away
                playerMovement.ISPlayerJumpFromWall = true;

                Vector3 jumpDirection = Vector3.up * wallJumpForce + wallNormal * wallJumpForce;

                Debug.Log("i am final");
                Invoke(nameof(SettheFinalWall), 0.3f);

                rb.AddForce(jumpDirection.normalized * wallJumpForce, ForceMode.Impulse);
                StopWallRun();
            }
            else
            {
                // Not final wall: jump towards next wall (left/right)
                playerMovement.ISPlayerJumpFromWall = true;

                Vector3 sideDir = rightWall ? Vector3.left : Vector3.right;
                Vector3 jumpDirection = sideDir * wallJumpForce + wallNormal * wallJumpForce;

                Debug.Log("i am not final");

                // Don't completely kill momentum, just avoid huge downward spikes
                Vector3 vel = rb.linearVelocity;
                if (vel.y < 0f) vel.y = 0f;
                rb.linearVelocity = vel;

                rb.AddForce(jumpDirection.normalized * wallJumpForce, ForceMode.Impulse);
                StopWallRun();
            }
        }
    }

    void SettheFinalWall()
    {
        Debug.Log("we overwrite");
        playerMovement.ISPlayerJumpFromWall = false;
    }

    // Optional: visualize wall check sphere in Scene view
    private void OnDrawGizmosSelected()
    {
        Gizmos.DrawWireSphere(transform.position, wallCheckDistance);
    }
}
