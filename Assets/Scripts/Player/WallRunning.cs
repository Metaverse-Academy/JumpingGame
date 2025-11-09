using System;
using Unity.Cinemachine;
using UnityEngine;
using UnityEngine.InputSystem;
using System.Collections;
using System.Collections.Generic;
using MoreMountains.Feedbacks;

public class WallRunning : MonoBehaviour
{
    [Header("Layer Masks")]
    [SerializeField] private LayerMask wallLayer;
    [SerializeField] private LayerMask groundLayer;
    [Header("References")]
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
    [SerializeField] private CinemachineCamera MainCamera;
    public MMF_Player wallRunStartFeedback;
    public CinemachineImpulseSource cameraImpulse;
    [Header("Wall Check Settings")]
    [SerializeField] private float wallCheckDistance = 1f;
    [SerializeField] private float minJumpHeight = 1.5f;

    private RaycastHit leftWallHit;
    private RaycastHit rightWallHit;
    private bool leftWall;
    private bool rightWall;
    public bool isWallRunning;
    private void Start()
    {
        rb = GetComponent<Rigidbody>();
        playerMovement = GetComponent<PlayerMovement>();
        playerInput = GetComponent<PlayerInput>();
    }
    void Update()
    {
        // Debug.Log("Is Wall Running: " + isWallRunning);
        // Debug.Log("Left Wall: " + leftWall + " Right Wall: " + rightWall);
        CheckForWall();
    }
    private IEnumerator CameraDutchReset()
    {
        yield return new WaitForSeconds(0.2f);
        MainCamera.Lens.Dutch = 0f;
    }
    void FixedUpdate()
    {
        if ((leftWall || rightWall))
        {
            if (!isWallRunning)
            {
                CameraSwitcher.instance.ActiveWallRun();
                StartWallRun();
            }

            WallRunningMovement();
        }
        else
        {
            if (isWallRunning )
            {
                 CameraSwitcher.instance.DeactiveWallRun();
                StopWallRun();
                
                
            }
        }
    }


    private void StopWallRun()
    {
        isWallRunning = false;
        rb.useGravity = true;
        StartCoroutine(CameraDutchReset());
        wallRunStartFeedback.StopFeedbacks();
    }
    // private IEnumerator WallRunningCooldown()
    // {
    //     while (wallRunTimer > 0)
    //     {
    //         wallRunTimer -= Time.deltaTime;
    //         yield return null;
    //     }
    // }

    private void WallRunningMovement()
    {
        
        
        wallRunStartFeedback.PlayFeedbacks();
        Vector3 wallNormal = rightWall ? rightWallHit.normal : leftWallHit.normal;
        Vector3 wallForward = Vector3.Cross(wallNormal, Vector3.up - wallNormal.y * Vector3.up);

        if ((orientation.forward - wallForward).magnitude > (orientation.forward - -wallForward).magnitude)
        {
            wallForward = -wallForward;
        }

        rb.AddForce(wallForward * wallRunForce, ForceMode.Force);

        // Optional: Add a slight upward force to counteract gravity
        rb.AddForce(Vector3.forward * (wallRunForce / 10), ForceMode.Force);
        rb.AddForce(-wallNormal * (wallRunForce / 4), ForceMode.Force);
        
        
            
        
    }

    private void StartWallRun()
    {
        isWallRunning = true;
        wallRunTimer = maxWallRunTime;
        rb.useGravity = false;
       // cameraImpulse.GenerateImpulse();

          

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
        leftWall = Physics.Raycast(transform.position, -orientation.right, out leftWallHit, wallCheckDistance, wallLayer);
        rightWall = Physics.Raycast(transform.position, orientation.right, out rightWallHit, wallCheckDistance, wallLayer);
    }
    public void OnWallJump(InputAction.CallbackContext context)
    {
        if (context.performed && isWallRunning)
        {
            Vector3 wallNormal = rightWall ? rightWallHit.normal : leftWallHit.normal;
            Vector3 jumpDirection;
            if(rightWall)
                jumpDirection = Vector3.up * wallJumpForce + wallNormal * wallJumpForce;
            else
                jumpDirection = Vector3.up  *wallJumpForce + wallNormal * wallJumpForce;

            rb.linearVelocity = new Vector3(rb.linearVelocity.x, 0f, rb.linearVelocity.z);
            rb.AddForce(jumpDirection.normalized     * wallJumpForce, ForceMode.Impulse);
            StopWallRun();
        }
    }


}