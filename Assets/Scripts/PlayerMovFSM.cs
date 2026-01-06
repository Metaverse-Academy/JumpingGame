using MoreMountains.Feedbacks;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;

public class PlayerMovFSM : MonoBehaviour
{
    private Rigidbody rb;
    private PlayerStateMachine fsm;

    [Header("Refs")]
    public GameObject groundCheck;
    public WallRunning wallRunning;
    public Transform cam;
    public Animator animator;

    [Header("Respawn")]
    [SerializeField] private Transform ReSpawnPos;

    [Header("VFX")]
    public ParticleSystem jumpEffectPrefab;

    [Header("Feedback")]
    [SerializeField] private MMF_Player jumpFeedback;

    [Header("Movement")]
    public float moveSpeed = 5f;
    public float jumpForce = 5f;

    [Header("Coyote Jump")]
    [SerializeField] private float coyoteTime = 0.15f;
    private float lastGroundedTime;

    [Header("Fall / Soft Landing")]
    [Range(0f, 3f)]
    public float fallGravityScale = 0.45f;
    public float fallVelocityThreshold = -0.1f;

    // Runtime
    public bool isGrounded { get; private set; }
    public Vector2 MovementInput { get; private set; }
    public bool IsWalkingInput { get; private set; }

    // Keep your original flag behavior
    public bool ISPlayerJumpFromWall = false;

    // Final wall lock: after final wall jump, wallrun can't start until grounded
    private bool finalWallExitLock = false;
    public bool FinalWallExitLocked => finalWallExitLock;
    private static PlayerMovFSM instance;

    // Small control lock after wall jump so normal movement doesn't overwrite instantly
    private float wallJumpControlLockTimer = 0f;

    public Rigidbody RB => rb;

    public bool GrappleActive
    {
        get
        {
            bool hookActive = HookingMechanic.instance != null && HookingMechanic.instance.isHooking;
            bool grapplingActive = Grappling.instance != null && Grappling.instance.isGrappling;
            return hookActive || grapplingActive;
        }
    }

    private void Awake()
    {

        if (instance != null && instance != this)
        {
            Destroy(gameObject);  
            return;
        }

        instance = this;
        DontDestroyOnLoad(gameObject); 
        rb = GetComponent<Rigidbody>();
        wallRunning = GetComponent<WallRunning>();
        fsm = GetComponent<PlayerStateMachine>();

        if (cam == null && Camera.main != null)
            cam = Camera.main.transform;
    }

    // Called by FSM each Update
    public void UpdateSensors()
    {
        isGrounded = Physics.Raycast(groundCheck.transform.position, Vector3.down, 2f);
        Debug.DrawRay(groundCheck.transform.position, Vector3.down * 2f, Color.red);

        if (isGrounded)
        {
            lastGroundedTime = Time.time;
            ISPlayerJumpFromWall = false;
            finalWallExitLock = false; // ONLY clear on ground
        }

        if (wallJumpControlLockTimer > 0f)
        {
            wallJumpControlLockTimer -= Time.deltaTime;
            if (wallJumpControlLockTimer <= 0f)
                ISPlayerJumpFromWall = false;
        }

        animator.SetBool("IsGrounded", isGrounded);
    }

    // ---------------- Input (New Input System) ----------------

    public void OnMove(InputAction.CallbackContext context)
    {
        MovementInput = context.ReadValue<Vector2>();

        if (context.performed) IsWalkingInput = true;

        if (context.canceled)
        {
            IsWalkingInput = false;
            animator.SetTrigger("StopWalking");
        }

        fsm.OnMove(MovementInput, context);
    }

    public void OnJump(InputAction.CallbackContext context)
    {
        if (!context.performed) return;
        fsm.OnJumpPressed();
    }

    // Keep separate action if you have it bound
    public void OnWallJump(InputAction.CallbackContext context)
    {
        if (!context.started) return;
        fsm.OnWallJumpPressed();
    }

    // ---------------- Helpers used by states ----------------

    public bool CanCoyoteJump() => (Time.time - lastGroundedTime) <= coyoteTime;
    public bool CanJumpNow() => isGrounded || CanCoyoteJump();
    public void ConsumeCoyote() => lastGroundedTime = -999f;

    public void DoNormalJump()
    {
        AudioMNG.instance.PlaySounds(2);
        if (jumpFeedback != null) jumpFeedback.PlayFeedbacks();
        SpawnJumpEffect(transform.position);

        rb.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);
        animator.SetTrigger("Jump");
    }

    public void ApplySoftFall()
    {
        if (GrappleActive) return;
        if (wallRunning != null && wallRunning.isWallRunning) return;
        if (isGrounded) return;

        if (rb.linearVelocity.y < fallVelocityThreshold)
        {
            Vector3 antiGravity = -Physics.gravity * (1f - fallGravityScale);
            rb.AddForce(antiGravity, ForceMode.Acceleration);
        }
    }

    public void ClearFinalWallExitLock()
{
    finalWallExitLock = false;
}

    public void ApplyCameraRelativeMove()
    {
        if (GrappleActive) return;
        if (wallRunning != null && wallRunning.isWallRunning) return;
        if (ISPlayerJumpFromWall) return;

        animator.SetFloat("Speed", MovementInput.magnitude);
        animator.SetBool("IsWalking", IsWalkingInput);

        Vector3 camForward, camRight;
        if (cam != null)
        {
            camForward = cam.forward; camForward.y = 0f; camForward.Normalize();
            camRight = cam.right;     camRight.y = 0f;   camRight.Normalize();
        }
        else
        {
            camForward = Vector3.forward;
            camRight   = Vector3.right;
        }

        Vector3 movement = camRight * MovementInput.x + camForward * MovementInput.y;

        Vector3 v = rb.linearVelocity;
        rb.linearVelocity = new Vector3(movement.x * moveSpeed, v.y, movement.z * moveSpeed);

        if (movement != Vector3.zero)
        {
            Quaternion targetRotation = Quaternion.LookRotation(movement);
            rb.rotation = Quaternion.Slerp(rb.rotation, targetRotation, Time.fixedDeltaTime * 10f);
        }
    }

    public void LockWallJumpControl(float seconds)
    {
        ISPlayerJumpFromWall = true;
        wallJumpControlLockTimer = Mathf.Max(wallJumpControlLockTimer, seconds);
    }

    public void SetFinalWallExitLock()
    {
        finalWallExitLock = true;
    }

    // ---------------- Misc ----------------

    private void SpawnJumpEffect(Vector3 position)
    {
        if (jumpEffectPrefab == null) return;
        var ps = Instantiate(jumpEffectPrefab, position, Quaternion.identity);
        ps.Play();
        var main = ps.main;
        float life = main.duration + main.startLifetime.constantMax;
        Destroy(ps.gameObject, life + 0.1f);
    }

    public void ReLoad()
    {
        transform.position = ReSpawnPos.position;
    }

    private void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Goal"))
            SceneManager.LoadScene("Prototype1");
    }
}
