// 11/8/2025 AI-Tag
// This was created with the help of Assistant, a Unity Artificial Intelligence product.

// This script handles basic Rigidbody-based movement and rotation for a 3D player using the new Unity Input System.

using System.Collections;
using MoreMountains.Feedbacks;
using MoreMountains.Tools;
using UnityEngine; // Import the UnityEngine namespace to access Unity-specific classes and functions.
using UnityEngine.InputSystem; // Import the InputSystem namespace to use the new Input System.

public class PlayerMovement : MonoBehaviour
{
    // Reference to the Rigidbody component attached to the player.
    private Rigidbody rb;

    // Movement speed of the player.
    [SerializeField] private MMF_Player jumpFeedback;
    public float moveSpeed = 5f;

    // Force applied for jumping.
    public float jumpForce = 5f;

    // Boolean to check if the player is grounded.
    private bool isGrounded;

    // Variable to store movement input.
    private Vector2 movementInput;
    public GameObject groundCheck;
    public WallRunning wallRunning;
    public Transform cam;
    public Animator animator;
    private bool pushed = false;

    // Start is called before the first frame update.
    void Start()
    {
        // Get the Rigidbody component attached to this GameObject.
        rb = GetComponent<Rigidbody>();
        if (cam == null && Camera.main != null)
        {
            cam = Camera.main.transform;
        }
    }

    // This method is called by the Input System when the "Move" action is triggered.
    public void OnMove(InputAction.CallbackContext context)
    {
        // Read the movement input from the Input System (e.g., WASD or arrow keys).
            if(context.started && isGrounded==true)AudioMNG.instance.Walking(1);
            movementInput = context.ReadValue<Vector2>();
            if(context.canceled&&isGrounded==true)AudioMNG.instance.Walking(0);

       // moveSpeed = Mathf.Lerp(0f, moveSpeed, 1f * Time.fixedDeltaTime); 
    }

    // This method is called by the Input System when the "Jump" action is triggered.
    public void OnJump(InputAction.CallbackContext context)
    {
        if (context.performed && isGrounded)
        {        
            AudioMNG.instance.PlaySounds(2);

            if (wallRunning.isWallRunning) return;
            // Apply an upward force to the Rigidbody for jumping.
            jumpFeedback.PlayFeedbacks();
            rb.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);
            animator.SetTrigger("Jump");
        }
    }

    // FixedUpdate is called at a fixed time interval and is used for physics calculations.
    void FixedUpdate()
    {
        if (wallRunning.isWallRunning) return;

        // BUILD MOVEMENT RELATIVE TO CAMERA (minimal change)
        //movement speed 

        animator.SetFloat("Speed", movementInput.magnitude);
        // Get camera forward/right, flatten them so movement stays on XZ plane
        Vector3 camForward = Vector3.zero;
        Vector3 camRight = Vector3.zero;
        if (cam != null)
        {
            camForward = cam.forward;
            camForward.y = 0f;
            camForward.Normalize();

            camRight = cam.right;
            camRight.y = 0f;
            camRight.Normalize();
        }
        else
        {
            // fallback to world axes if no camera assigned
            camForward = Vector3.forward;
            camRight = Vector3.right;
        }

        Vector3 movement = camRight * movementInput.x + camForward * movementInput.y;

        // preserve vertical velocity (you're using linearVelocity in your original)
        if (pushed == true) return;
        rb.linearVelocity = new Vector3(movement.x * moveSpeed, rb.linearVelocity.y, movement.z * moveSpeed);

        isGrounded = Physics.Raycast(groundCheck.transform.position, Vector3.down, 1.1f);
        animator.SetBool("IsGrounded", isGrounded); 
        if (movement != Vector3.zero)
        {
            Quaternion targetRotation = Quaternion.LookRotation(movement);
            rb.rotation = Quaternion.Slerp(rb.rotation, targetRotation, Time.fixedDeltaTime * 10f);
        }
    }

    // void FixedUpdate()
    // {
    //     if(wallRunning.isWallRunning) return;
    //     // Apply movement based on the input received from OnMove.
    //     Vector3 movement = new Vector3(movementInput.x, 0.0f, movementInput.y);
    //     rb.linearVelocity = new Vector3(movement.x * moveSpeed, rb.linearVelocity.y, movement.z * moveSpeed);

    //     // Check if the player is grounded by casting a ray downwards from the groundCheck object's position.
    //     isGrounded = Physics.Raycast(groundCheck.transform.position, Vector3.down, 1.1f);

    //     // Rotate the player to face the movement direction if there is movement.
    //     if (movement != Vector3.zero) // Check if there is movement input.
    //     {
    //         Quaternion targetRotation = Quaternion.LookRotation(movement); // Calculate the rotation needed to face the movement direction.
    //         rb.rotation = Quaternion.Slerp(rb.rotation, targetRotation, Time.fixedDeltaTime * 10f); // Smoothly rotate the player towards the target direction.
    //     }
    // }
    public IEnumerator  setPushed()
    {
        pushed = true;
        yield return new WaitForSeconds(1f);
        pushed = false;
    }
}