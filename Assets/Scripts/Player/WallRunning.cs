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

    // 🔹 New: control speed & stickiness
    [SerializeField] private float targetWallRunSpeed = 12f;
    [SerializeField] private float wallStickForce = 30f;
    [SerializeField] private float maxDownwardWallSpeed = -5f;

    [SerializeField] private CinemachineCamera WallRunCamera;
    public MMF_Player wallRunStartFeedback;
    public CinemachineImpulseSource cameraImpulse;

    [Header("Wall Check Settings")]
    [SerializeField] private float wallCheckDistance = 1f;
    [SerializeField] private float minJumpHeight = 1.5f;
    [SerializeField] private Animator animator;

    private RaycastHit leftWallHit;
    private RaycastHit rightWallHit;

    private float mainCameraleftDutch = -10f;
    private float mainCameraRightDutch = 10f;

    private bool leftWall;
    private bool rightWall;

    public GameObject trailEffect;
    public bool isWallRunning;
    public WallData TheWallThePlayerRunOnIt;

    // i do this bool vvvv cus i want the StartWallRun Func run one time 
    bool StartRunOnTime = false;

    private void Start()
    {
        rb = GetComponent<Rigidbody>();
        playerMovement = GetComponent<PlayerMovement>();
        playerInput = GetComponent<PlayerInput>();
    }

    private void Update()
    {
        // UI anims
        BlackFramUp.SetBool("IsWallRun", playerMovement.ISPlayerJumpFromWall);
        BlackFramDown.SetBool("IsWallRunning", playerMovement.ISPlayerJumpFromWall);

        // Adjust wall jump force based on wall data
        if (TheWallThePlayerRunOnIt)
        {
            if (TheWallThePlayerRunOnIt.IsFinalWall)
            {
                wallJumpForce = 22f;
            }
            else
            {
                wallJumpForce = 38f;
            }
        }

        // ⛔ Removed: code that was zeroing velocity when not wallrunning
        // It was killing your momentum between walls.

        CheckForWall();

        // Optional: timer for wall running cooldown (if you want to use it later)
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
                // CameraSwitcher.instance.ActiveWallRun();
                StartWallRun();
            }

            WallRunningMovement();
        }
        else
        {
            if (isWallRunning)
            {
                // CameraSwitcher.instance.DeactiveWallRun();
                StopWallRun();
            }
        }
    }

    private void StopWallRun()
    {
        AudioMNG.instance.WallRun(0);

        Debug.Log("stop running");
        animator.SetBool("IsWallRunning", false);
        animator.SetBool("IsWallRunningLeft", false);

        isWallRunning = false;

        rb.useGravity = true;
        trailEffect.SetActive(false);

        StartCoroutine(CameraDutchReset());
        // wallRunStartFeedback.StopFeedbacks();
    }

    private void WallRunningMovement()
    {
        // Camera tilt + anims
        if (leftWall)
        {
            WallRunCamera.Lens.Dutch = Mathf.Lerp(
                WallRunCamera.Lens.Dutch,
                -mainCameraleftDutch,
                Time.fixedDeltaTime * 1f
            );
            animator.SetBool("IsWallRunningLeft", true);
            AudioMNG.instance.WallRun(1);
        }
        else if (rightWall)
        {
            WallRunCamera.Lens.Dutch = Mathf.Lerp(
                WallRunCamera.Lens.Dutch,
                mainCameraRightDutch,
                Time.fixedDeltaTime * 1f
            );
            animator.SetBool("IsWallRunning", true);
            AudioMNG.instance.WallRun(1);
        }

        // --- Wall forward direction ---

        Vector3 wallNormal = rightWall ? rightWallHit.normal : leftWallHit.normal;

        // Direction along the wall (perpendicular to normal & up)
        Vector3 wallForward = Vector3.Cross(wallNormal, Vector3.up).normalized;

        // Make sure it's aligned with where the player looks
        if (Vector3.Dot(wallForward, orientation.forward) < 0f)
        {
            wallForward = -wallForward;
        }

        // --- Preserve & reshape momentum ---

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

        // If we are too slow along the wall, push towards a target speed
        float currentSpeedAlongWall = velAlongWall.magnitude;

        if (currentSpeedAlongWall < targetWallRunSpeed)
        {
            velAlongWall = wallForward * targetWallRunSpeed;
        }
        else
        {
            velAlongWall = wallForward * currentSpeedAlongWall;
        }

        // Apply combined velocity: along wall + vertical
        rb.linearVelocity = new Vector3(velAlongWall.x, verticalVel, velAlongWall.z);

        // Push slightly into the wall to keep us attached
        rb.AddForce(-wallNormal * wallStickForce, ForceMode.Acceleration);

        // Extra forward force if you still want it (small)
        rb.AddForce(wallForward * wallRunForce, ForceMode.Force);
    }

    private void StartWallRun()
    {
        if (StartRunOnTime == false)
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

    private void CheckForWall()
    {
        leftWall = Physics.Raycast(
            transform.position,
            -orientation.right,
            out leftWallHit,
            wallCheckDistance,
            wallLayer
        );

        rightWall = Physics.Raycast(
            transform.position,
            orientation.right,
            out rightWallHit,
            wallCheckDistance,
            wallLayer
        );

        if (rightWallHit.collider != null)
        {
            TheWallThePlayerRunOnIt = rightWallHit.collider.gameObject.GetComponent<WallData>();
            Debug.Log(TheWallThePlayerRunOnIt.IsFinalWall);
        }

        if (leftWallHit.collider != null)
        {
            TheWallThePlayerRunOnIt = leftWallHit.collider.gameObject.GetComponent<WallData>();
            Debug.Log(TheWallThePlayerRunOnIt.IsFinalWall);
        }
    }

    public void OnWallJump(InputAction.CallbackContext context)
    {
        if (context.started && isWallRunning && TheWallThePlayerRunOnIt != null)
        {
            Vector3 wallNormal = rightWall ? rightWallHit.normal : leftWallHit.normal;

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

                Vector3 jumpDirection;
                if (rightWall)
                    jumpDirection = Vector3.left * wallJumpForce + wallNormal * wallJumpForce;
                else
                    jumpDirection = Vector3.right * wallJumpForce + wallNormal * wallJumpForce;

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
}
