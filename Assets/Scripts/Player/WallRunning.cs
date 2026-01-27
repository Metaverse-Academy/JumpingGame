using UnityEngine;

public class WallRunning : MonoBehaviour
{
    [Header("Setup")]
    public LayerMask wallLayer;
    public Rigidbody rb;
    public PlayerMovement motor; // <- if your motor is named PlayerMovFSM, change this type

    [Header("Detection")]
    public float wallCheckDistance = 0.8f;
    public string leftWallTag = "WallLeft";
    public string rightWallTag = "WallRight";

    [Header("Run")]
    public float wallRunTargetSpeed = 12f;
    public float wallRunLerpSpeed = 10f;

    [Header("Jump")]
    public float wallJumpSidewaysForce = 15f;      // "away from wall"
    public float wallJumpUpwardForce = 0f;         // non-final upward (set 0 if you want pure sideways)
    public float finalWallExtraUpwardForce = 6f;   // extra upward on final wall

    [Header("Wall Grace")]
    public float wallDetachCoyoteTime = 0.15f;     // jump allowed shortly after losing wall

    public bool isWallRunning { get; private set; }
    public WallData currentWallData { get; private set; }

    private Collider currentWallCollider;
    [SerializeField]private Animator animator;
    private Vector3 currentWallNormal;

    private float lastWallTouchTime = -999f;
    private Vector3 lastWallNormal = Vector3.right;
    private bool lastWallWasFinal = false;

    private bool leftWall;
    private bool rightWall;

    private void Awake()
    {
        if (rb == null) rb = GetComponent<Rigidbody>();
        if (motor == null) motor = GetComponent<PlayerMovement>(); // change if your motor class name differs
    }

    private void Update()
    {
        CheckForWall();

        // If we are wallrunning but lost the wall, end.
        if (isWallRunning && !HasRunnableWall())
            EndWallRun();
    }

    public bool HasRunnableWall() => currentWallCollider != null;

    private bool HasRecentWallContact() => (Time.time - lastWallTouchTime) <= wallDetachCoyoteTime;

    public bool CanStartWallRun()
    {
        // FSM decides when to start; this just tells if wall exists
        if (motor != null && motor.isGrounded) return false;
        return HasRunnableWall();
    }

    public void BeginWallRun()
    {
        if (!HasRunnableWall() || isWallRunning) return;

        isWallRunning = true;
        animator.SetBool("IsWallRunning", true);

        rb.useGravity = false;

        // optional: remove downward velocity so it feels sticky
        Vector3 vel = rb.linearVelocity;
        if (vel.y < 0f)
        {
            vel.y = 0f;
            rb.linearVelocity = vel;
        }
    }

    public void EndWallRun()
    {
        if (!isWallRunning) return;
        isWallRunning = false;
        rb.useGravity = true;
        animator.SetBool("IsWallRunning", false);
    }

    public void TickWallRunMovement()
    {
        if (!isWallRunning) return;
        if (!HasRunnableWall()) return;

        // Keeps your original "run along world forward" behavior
        Vector3 wallForward = Vector3.forward;

        Vector3 v = rb.linearVelocity;
        Vector3 currentHoriz = new Vector3(v.x, 0f, v.z);
        Vector3 targetHoriz = wallForward * wallRunTargetSpeed;

        Vector3 lerped = Vector3.Lerp(currentHoriz, targetHoriz, wallRunLerpSpeed * Time.fixedDeltaTime);
        rb.linearVelocity = new Vector3(lerped.x, 0f, lerped.z); // lock Y to 0 while wallrunning
    }

    /// <summary>
    /// Wall jump that does NOT depend on movement input.
    /// Works while wallrunning OR within grace time after losing wall.
    /// </summary>
    public bool TryWallJump(out bool jumpedFromFinalWall)
    {
        jumpedFromFinalWall = false;

        bool hasWallNow = HasRunnableWall();
        bool hasRecent = HasRecentWallContact();
        if (!hasWallNow && !hasRecent) return false;

        // Use current if available; else last known within grace
        Vector3 awayFromWall = hasWallNow ? currentWallNormal : lastWallNormal;
        bool onFinalWall = false;

        if (hasWallNow && currentWallData != null) onFinalWall = currentWallData.IsFinalWall;
        else onFinalWall = lastWallWasFinal;

        jumpedFromFinalWall = onFinalWall;

        float up = wallJumpUpwardForce + (onFinalWall ? finalWallExtraUpwardForce : 0f);

        // Side (away) + Up (final adds extra)
        Vector3 impulse = (awayFromWall.normalized * wallJumpSidewaysForce) + (Vector3.up * up);

        // Clear downward velocity so jump feels consistent
        Vector3 vel = rb.linearVelocity;
        if (vel.y < 0f) vel.y = 0f;
        rb.linearVelocity = vel;

        if (motor != null)
            motor.ISPlayerJumpFromWall = true;

        rb.AddForce(impulse, ForceMode.Impulse);

        EndWallRun();
        return true;
    }

    private void CheckForWall()
    {
        currentWallCollider = null;
        currentWallData = null;
        currentWallNormal = Vector3.zero;
        leftWall = false;
        rightWall = false;

        // Find a wall collider near us
        Collider[] hits = Physics.OverlapSphere(transform.position, wallCheckDistance, wallLayer);
        if (hits == null || hits.Length == 0) return;

        // Pick the closest one (stable)
        float best = float.MaxValue;
        Collider bestCol = null;

        for (int i = 0; i < hits.Length; i++)
        {
            float d = (hits[i].ClosestPoint(transform.position) - transform.position).sqrMagnitude;
            if (d < best)
            {
                best = d;
                bestCol = hits[i];
            }
        }

        currentWallCollider = bestCol;
        if (currentWallCollider == null) return;

        // Optional: keep your left/right tags (only if you still use them elsewhere)
        if (currentWallCollider.CompareTag(leftWallTag)) leftWall = true;
        if (currentWallCollider.CompareTag(rightWallTag)) rightWall = true;

        currentWallData = currentWallCollider.GetComponent<WallData>();

        // Compute normal robustly
        Vector3 closest = currentWallCollider.ClosestPoint(transform.position);
        currentWallNormal = (transform.position - closest).normalized; // points away from wall

        // Ignore floor-like surfaces so top-of-wall doesn't count as a wall
    float upDot = Vector3.Dot(currentWallNormal, Vector3.up);
    if (upDot > 0.2f)
    {
        currentWallCollider = null;
        currentWallData = null;
        currentWallNormal = Vector3.zero;
        return;
    }

        // Store for grace window
        lastWallTouchTime = Time.time;
        lastWallNormal = currentWallNormal;
        lastWallWasFinal = (currentWallData != null && currentWallData.IsFinalWall);
    }
}
