using System;
using System.Collections;
using System.Collections.Generic;
using Unity.Mathematics;
using UnityEngine;
using Unity.Cinemachine;
using UnityEngine.InputSystem;


[RequireComponent(typeof(Rigidbody))]
[RequireComponent(typeof(PlayerInput))]
public class PlayerMovementTutorial : MonoBehaviour
{

    [Header("References")]
    [SerializeField] private CinemachineCamera MainCamera;
    [Header("Movement")]
    public float walkSpeed = 5f;
    public float sprintSpeed = 9f;
    public float airMultiplier = 0.6f;

    [Header("Jump")]
    public float jumpForce = 5f;
    public float jumpCooldown = 0.2f;

    [Header("Ground")]
    public float playerHeight = 2f;
    public LayerMask whatIsGround;
    public GameObject groundCheck;
    public float groundDrag = 4f;
    [Header("Dash")]
    public float dashForce = 25f;
    public float dashDuration = 0.2f;
    public float dashUpwardForce = 0f;
    public float dashCooldown = 1f;

    [Header("Slide")]
    [Header("FOV")]
    public float normalFOV = 70f;
    public float slideFOV = 90f;
    public float fovDuration = 0.25f;
    public LeanTweenType fovEase = LeanTweenType.easeOutSine;

    [Header("Tilt (Dutch)")]
    [Tooltip("Positive = clockwise roll in degrees")]
    public float normalDutch = 0f;
    public float slideDutch = 6f;
    public float dutchDuration = 0.25f;
    public LeanTweenType dutchEase = LeanTweenType.easeOutSine;

    // Internal handles so we can cancel specific tweens if needed
    private int fovTweenId = -1;
    private int dutchTweenId = -1;


    [Header("Orientation (player facing)")]
    public Transform orientation; // player root (used for forward/right)

    // runtime
    private Rigidbody rb;
    private bool grounded;
    private bool readyToJump = true;
    private bool isSprinting = false;
    private Vector2 moveInput = Vector2.zero;
    private float moveSpeed;

    void Awake()
    {
        rb = GetComponent<Rigidbody>();
        rb.freezeRotation = true;

        if (orientation == null) orientation = transform;
        moveSpeed = walkSpeed;
    }

    void Update()
    {
        // ground check
        Vector3 origin = groundCheck != null ? groundCheck.transform.position : transform.position;
        grounded = Physics.Raycast(origin, Vector3.down, playerHeight * 0.5f + 0.3f, whatIsGround);

        // drag
        rb.linearDamping = grounded ? groundDrag : 0f;

    }


    void FixedUpdate()
    {
        MovePlayer();
        SpeedControl();
    }



    public void OnMove(InputAction.CallbackContext ctx)
    {
      //  Debug.Log("Moving input: " + ctx.ReadValue<Vector2>());
        moveInput = ctx.ReadValue<Vector2>();
    }

    public void OnJump(InputAction.CallbackContext ctx)
    {
        if (!ctx.performed) return;
        if (!readyToJump || !grounded) return;

        readyToJump = false;
        Jump();
        Invoke(nameof(ResetJump), jumpCooldown);
    }
    public void OnDash(InputAction.CallbackContext ctx)
    {
        if (ctx.performed)
        {
            Debug.Log("Dashing");
            Vector3 Addforce = orientation.forward * dashForce + Vector3.up * dashUpwardForce;
            Addforce = math.lerp(Addforce, Vector3.zero, dashDuration);
            rb.AddForce(Addforce, ForceMode.VelocityChange);
        }
    }

    public void OnSprint(InputAction.CallbackContext ctx)
    {
        // if (ctx.started || ctx.performed)
        // {
        //     isSprinting = true;
        // }
        // if (ctx.canceled)
        // {
        //     isSprinting = false;
        // }

        // moveSpeed = isSprinting ? sprintSpeed : walkSpeed;
    }


    public void onSlide(InputAction.CallbackContext ctx)
    {
        if (ctx.performed)
        {


        }
    }

        void MovePlayer()
        {
           // Debug.Log("Moving player");
            Vector3 dir = orientation.forward * moveInput.y + orientation.right * moveInput.x;
            dir = dir.normalized;

            if (grounded)
                rb.AddForce(dir * moveSpeed * 10f, ForceMode.Force);
            else
                rb.AddForce(dir * moveSpeed * 10f * airMultiplier, ForceMode.Force);
        }

        void SpeedControl()
        {
           // Debug.Log("Controlling speed");
            Vector3 flatVel = new Vector3(rb.linearVelocity.x, 0f, rb.linearVelocity.z);

            if (flatVel.magnitude > moveSpeed)
            {
                Vector3 limited = flatVel.normalized * moveSpeed;
                rb.linearVelocity = new Vector3(limited.x, rb.linearVelocity.y, limited.z);
            }
        }

        void Jump()
        {
            // reset Y velocity then impulse up
            rb.linearVelocity = new Vector3(rb.linearVelocity.x, 0f, rb.linearVelocity.z);
            rb.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);
        }

        void ResetJump()
        {
            readyToJump = true;
        }

        void OnDrawGizmos()
        {
            Vector3 origin = groundCheck != null ? groundCheck.transform.position : transform.position;
            Gizmos.color = Color.red;
            Gizmos.DrawRay(origin, Vector3.down * (playerHeight * 0.5f + 0.3f));
        }
    }
