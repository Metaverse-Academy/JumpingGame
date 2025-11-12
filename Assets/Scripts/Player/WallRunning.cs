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
    [SerializeField] private CinemachineCamera WallRunCamera;
    public MMF_Player wallRunStartFeedback;
    public CinemachineImpulseSource cameraImpulse;
    [Header("Wall Check Settings")]
    [SerializeField] private float wallCheckDistance = 1f;
    [SerializeField] private float minJumpHeight = 1.5f;
    [SerializeField] private Animator animator;

    private RaycastHit leftWallHit;
    private RaycastHit rightWallHit;
    private float mainCameraleftDutch=-10f;
    private float mainCameraRightDutch  =10f;
    private bool leftWall;
    private bool rightWall;
    public GameObject trailEffect;
    public bool isWallRunning;
    public WallData TheWallThePlayerRunOnIt;

    private void Start()
    {
        rb = GetComponent<Rigidbody>();
        playerMovement = GetComponent<PlayerMovement>();
        playerInput = GetComponent<PlayerInput>();
    }
    void Update()
    {

        if (playerMovement.isGrounded == true)
        {
            isWallRunning = false;
        }
        // Debug.Log("Is Wall Running: " + isWallRunning);
        // Debug.Log("Left Wall: " + leftWall + " Right Wall: " + rightWall);
        CheckForWall();
        // if (isWallRunning == true)
        // {
        //     playerMovement.SetIsPlayerStartToJump();
        // }

       
       
    }
    private IEnumerator CameraDutchReset()
    {
        yield return new WaitForSeconds(0.2f);
        WallRunCamera.Lens.Dutch = 0f;
    }
    void FixedUpdate()
    {
        if ((leftWall || rightWall))
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
                // WallRunCamera.Lens.Dutch = Mathf.Lerp(WallRunCamera.Lens.Dutch, 0f, Time.fixedDeltaTime * 2f);


            }
        }
    }


    private void StopWallRun()
    {
            AudioMNG.instance.WallRun(0);

        Debug.Log("stop running");
        animator.SetBool("IsWallRunning", false);
        animator.SetBool("IsWallRunningLeft", false);
            // AudioMNG.instance.WallRun(0);
 
        
        rb.useGravity = true;
        trailEffect.SetActive(false);
        //animator.SetBool("IsWallRunning", false);
        // WallRunCamera.Lens.Dutch = Mathf.Lerp(WallRunCamera.Lens.Dutch, 0f, Time.fixedDeltaTime * 2f);
         StartCoroutine(CameraDutchReset());
//        wallRunStartFeedback.StopFeedbacks();
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

        if (leftWall)
        {
            WallRunCamera.Lens.Dutch = Mathf.Lerp(WallRunCamera.Lens.Dutch, -mainCameraleftDutch, Time.fixedDeltaTime * 1f);
            animator.SetBool("IsWallRunningLeft", true);
            AudioMNG.instance.WallRun(1);

        }
           
        else if (rightWall)
        {
            WallRunCamera.Lens.Dutch = Mathf.Lerp(WallRunCamera.Lens.Dutch, mainCameraRightDutch, Time.fixedDeltaTime * 1f);
            animator.SetBool("IsWallRunning", true);
            AudioMNG.instance.WallRun(1);

        }
            
        
           
        Vector3 wallNormal = rightWall ? rightWallHit.normal : leftWallHit.normal;
        Vector3 wallForward = Vector3.Cross(wallNormal, Vector3.up - wallNormal.y * Vector3.up);

        if ((orientation.forward - wallForward).magnitude > (orientation.forward - -wallForward).magnitude)
        {
            wallForward = -wallForward;
        }
        
        // rb.linearVelocity = new Vector3(rb.linearVelocity.x, 0, rb.linearVelocity.z);

        rb.AddForce(Vector3.forward * wallRunForce, ForceMode.Force);

        // Optional: Add a slight upward force to counteract gravity
        rb.AddForce(Vector3.forward * (wallRunForce / 10), ForceMode.Force);
        rb.AddForce(-wallNormal * (wallRunForce / 4), ForceMode.Force);
        
        
            
        
    }

    private void StartWallRun()
    {
       

        isWallRunning = true;
        wallRunTimer = maxWallRunTime;
        rb.useGravity = false;
        trailEffect.SetActive(true);
        wallRunStartFeedback.PlayFeedbacks();       
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
        // if (leftWallHit.collider != null )
        // {
            
        //             TheWallThePlayerRunOnIt = leftWallHit.collider.gameObject.GetComponent<WallData>();

        // }

        rightWall = Physics.Raycast(transform.position, orientation.right, out rightWallHit, wallCheckDistance, wallLayer);
// if (rightWallHit.collider != null )
//         {
            
//                     TheWallThePlayerRunOnIt = rightWallHit.collider.gameObject.GetComponent<WallData>();

//         }
    }
    public void OnWallJump(InputAction.CallbackContext context)
    {
        if (context.performed && isWallRunning)
        {
            // if (TheWallThePlayerRunOnIt!= null && TheWallThePlayerRunOnIt.IsFinalWall == true)
            // {
            //     Vector3 wallNormal = rightWall ? rightWallHit.normal : leftWallHit.normal;
            //     Vector3 jumpDirection;
            //     if (rightWall)
            //         jumpDirection = Vector3.up * wallJumpForce + wallNormal * wallJumpForce;
            //     else
            //         jumpDirection = Vector3.up * wallJumpForce + wallNormal * wallJumpForce;

            //     rb.linearVelocity = new Vector3(rb.linearVelocity.x, 0f, rb.linearVelocity.z);
            //     rb.AddForce(jumpDirection.normalized * wallJumpForce, ForceMode.Impulse);
            //     StopWallRun();



            // }


            Vector3 wallNormal = rightWall ? rightWallHit.normal : leftWallHit.normal;
            Vector3 jumpDirection;
            if (rightWall)
                jumpDirection = Vector3.left * wallJumpForce + wallNormal * wallJumpForce;
            else
                jumpDirection = Vector3.right * wallJumpForce + wallNormal * wallJumpForce;

            rb.linearVelocity = new Vector3(rb.linearVelocity.x, 0f, rb.linearVelocity.z);
            rb.AddForce(jumpDirection.normalized * wallJumpForce, ForceMode.Impulse);
            StopWallRun();
        }
            

        //     else if(TheWallThePlayerRunOnIt!= null && TheWallThePlayerRunOnIt.IsFinalWall == false)
        //     {
                

        // }
    }


}