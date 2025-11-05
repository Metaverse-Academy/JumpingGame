// 11/5/2025 AI-Tag
// This was created with the help of Assistant, a Unity Artificial Intelligence product.

using System;
using UnityEditor;
using UnityEngine;
using UnityEngine.InputSystem;
using Unity.Cinemachine;

public class ThirdPersonPlayerController : MonoBehaviour
{
    public float moveSpeed = 5f;
    public float jumpForce = 5f;
    public float slideForce = 10f;
    public float rotationSpeed = 10f;

    public Rigidbody playerRigidbody;
    public Transform cameraTransform;
    public CinemachineCamera cinemachineCamera;

    private Vector2 moveInput;
    private Vector2 lookInput;
    private bool isSliding = false;

    public void OnMove(InputAction.CallbackContext context)
    {
        moveInput = context.ReadValue<Vector2>();
    }

    public void OnLook(InputAction.CallbackContext context)
    {
        lookInput = context.ReadValue<Vector2>();
    }

    public void OnJump(InputAction.CallbackContext context)
    {
        if (context.performed && IsGrounded())
        {
            playerRigidbody.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);
        }
    }

    public void OnSlide(InputAction.CallbackContext context)
    {
        if (context.performed && IsGrounded() && !isSliding)
        {
            isSliding = true;
            Vector3 slideDirection = transform.forward * slideForce;
            playerRigidbody.AddForce(slideDirection, ForceMode.Impulse);
            Invoke("StopSliding", 0.5f); // Slide for 0.5 seconds
        }
    }

    public void OnAim(InputAction.CallbackContext context)
    {
        if (context.performed) // Right mouse button pressed
        {
           // cinemachineCamera.m_XAxis.m_InputAxisName = "Mouse X";
           // cinemachineCamera.m_YAxis.m_InputAxisName = "Mouse Y";
        }
        else if (context.canceled) // Right mouse button released
        {
            //cinemachineCamera.m_XAxis.m_InputAxisName = "";
            //cinemachineCamera.m_YAxis.m_InputAxisName = "";
        }
    }

    void Start()
    {
        if (playerRigidbody == null)
        {
            playerRigidbody = GetComponent<Rigidbody>();
        }
    }

    void Update()
    {
        HandleMovement();
    }

    void HandleMovement()
    {
        Vector3 direction = new Vector3(moveInput.x, 0, moveInput.y).normalized;

        if (direction.magnitude >= 0.1f)
        {
            float targetAngle = Mathf.Atan2(direction.x, direction.z) * Mathf.Rad2Deg + cameraTransform.eulerAngles.y;
            float angle = Mathf.SmoothDampAngle(transform.eulerAngles.y, targetAngle, ref rotationSpeed, 0.1f);
            transform.rotation = Quaternion.Euler(0, angle, 0);

            Vector3 moveDirection = Quaternion.Euler(0, targetAngle, 0) * Vector3.forward;
            playerRigidbody.MovePosition(transform.position + moveDirection * moveSpeed * Time.deltaTime);
        }
    }

    void StopSliding()
    {
        isSliding = false;
    }

    bool IsGrounded()
    {
        return Physics.Raycast(transform.position, Vector3.down, 0.1f);
    }
}
