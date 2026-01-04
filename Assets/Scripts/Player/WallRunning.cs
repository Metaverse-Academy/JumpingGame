using System.Collections;
using Unity.Cinemachine;
using UnityEngine;
using MoreMountains.Feedbacks;

public class WallRunning : MonoBehaviour
{
    public LayerMask wallLayer;

    public PlayerMovFSM playerMovement;
    public Rigidbody rb;

    public CinemachineCamera wallRunCamera;
    public MMF_Player wallRunStartFeedback;
    public GameObject trailEffect;

    public string leftWallTag = "WallLeft";
    public string rightWallTag = "WallRight";

    public float wallCheckDistance = 0.8f;
    public float wallRunTargetSpeed = 12f;
    public float wallRunLerpSpeed = 8f;

    public float wallJumpForce = 10f;

    public float cameraTiltAmount = 10f;
    public float cameraTiltLerpSpeed = 10f;

    public float wallRunningCooldown = 0.4f;

    public bool isWallRunning;
    public WallData currentWallData;

    private bool leftWall;
    private bool rightWall;

    private float wallRunningCooldownTimer;

    private Collider currentWallCollider;

    private void Start()
    {
        if (rb == null) rb = GetComponent<Rigidbody>();
        if (playerMovement == null) playerMovement = GetComponent<PlayerMovFSM>();
    }

    private void Update()
    {
        CheckForWall();

        if (wallRunningCooldownTimer > 0f)
            wallRunningCooldownTimer -= Time.deltaTime;
    }

    public bool HasRunnableWall() => leftWall || rightWall;

    public bool CanStartWallRun()
    {
        if (wallRunningCooldownTimer > 0f) return false;
        if (playerMovement != null && playerMovement.isGrounded) return false;
        return HasRunnableWall();
    }

    public void BeginWallRun()
    {
        if (!HasRunnableWall()) return;

        isWallRunning = true;
        rb.useGravity = false;

        if (trailEffect != null) trailEffect.SetActive(true);
        if (wallRunStartFeedback != null) wallRunStartFeedback.PlayFeedbacks();

        Vector3 vel = rb.linearVelocity;
        if (vel.y < 0f) { vel.y = 0f; rb.linearVelocity = vel; }

        AudioMNG.instance.WallRun(1);
    }

    public void EndWallRun()
    {
        isWallRunning = false;
        rb.useGravity = true;

        if (trailEffect != null) trailEffect.SetActive(false);

        AudioMNG.instance.WallRun(0);

        wallRunningCooldownTimer = wallRunningCooldown;
        StartCoroutine(CameraDutchReset());
    }

    public void TickWallRunMovement()
    {
        if (!isWallRunning) return;
        if (!HasRunnableWall()) return;

        if (wallRunCamera != null)
        {
            float targetTilt = leftWall ? -cameraTiltAmount : (rightWall ? cameraTiltAmount : 0f);
            wallRunCamera.Lens.Dutch = Mathf.Lerp(
                wallRunCamera.Lens.Dutch,
                targetTilt,
                cameraTiltLerpSpeed * Time.fixedDeltaTime
            );
        }

        Vector3 wallForward = Vector3.forward;

        Vector3 currentVel = rb.linearVelocity;
        Vector3 currentHoriz = new Vector3(currentVel.x, 0f, currentVel.z);
        Vector3 targetHoriz = wallForward * wallRunTargetSpeed;

        Vector3 lerpedHoriz = Vector3.Lerp(currentHoriz, targetHoriz, wallRunLerpSpeed * Time.fixedDeltaTime);
        rb.linearVelocity = new Vector3(lerpedHoriz.x, 0f, lerpedHoriz.z);
    }

    public bool TryWallJump(out bool jumpedFromFinalWall)
    {
        jumpedFromFinalWall = false;

        if (!isWallRunning) return false;
        if (currentWallData == null) return false;

        Vector3 jumpDirection;

        if (currentWallData.IsFinalWall)
        {
            jumpedFromFinalWall = true;
            jumpDirection = Vector3.up;
        }
        else
        {
            float xDir = leftWall ? 2f : -2f;
            jumpDirection = new Vector3(xDir, 0.5f, 0f).normalized;
        }

        playerMovement.ISPlayerJumpFromWall = true;

        Vector3 vel = rb.linearVelocity;
        if (vel.y < 0f) vel.y = 0f;
        rb.linearVelocity = vel;

        rb.AddForce(jumpDirection * wallJumpForce, ForceMode.Impulse);

        EndWallRun();
        return true;
    }

    private void CheckForWall()
    {
        leftWall = false;
        rightWall = false;
        currentWallCollider = null;
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
            currentWallData = currentWallCollider.GetComponent<WallData>();
    }

    private IEnumerator CameraDutchReset()
    {
        yield return new WaitForSeconds(0.2f);
        if (wallRunCamera != null) wallRunCamera.Lens.Dutch = 0f;
    }
}
