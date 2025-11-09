// 11/8/2025 AI-Tag
// This was created with the help of Assistant, a Unity Artificial Intelligence product.

// This script handles basic Rigidbody-based movement and rotation for a 3D player using the new Unity Input System.

using UnityEngine; // Import the UnityEngine namespace to access Unity-specific classes and functions.
using UnityEngine.InputSystem; // Import the InputSystem namespace to use the new Input System.

public class PlayerMovement : MonoBehaviour
{
    // Reference to the Rigidbody component attached to the player.
    private Rigidbody rb;

    // Movement speed of the player.
    public float moveSpeed = 5f;

    // Force applied for jumping.
    public float jumpForce = 5f;

    // Boolean to check if the player is grounded.
    private bool isGrounded;

    // Variable to store movement input.
    private Vector2 movementInput;
    public GameObject groundCheck;
    public WallRunning wallRunning;

    // Start is called before the first frame update.
    void Start()
    {
        // Get the Rigidbody component attached to this GameObject.
        rb = GetComponent<Rigidbody>();
    }

    // This method is called by the Input System when the "Move" action is triggered.
    public void OnMove(InputAction.CallbackContext context)
    {
        // Read the movement input from the Input System (e.g., WASD or arrow keys).
        movementInput = context.ReadValue<Vector2>();
    }

    // This method is called by the Input System when the "Jump" action is triggered.
    public void OnJump(InputAction.CallbackContext context)
    {
        // Check if the jump button is pressed and the player is grounded.
        if (context.performed && isGrounded)
        {
            if(wallRunning.isWallRunning) return;
            // Apply an upward force to the Rigidbody for jumping.
            rb.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);
        }
    }

    // FixedUpdate is called at a fixed time interval and is used for physics calculations.
    void FixedUpdate()
    {
        if(wallRunning.isWallRunning) return;
        // Apply movement based on the input received from OnMove.
        Vector3 movement = new Vector3(movementInput.x, 0.0f, movementInput.y);
        rb.linearVelocity = new Vector3(movement.x * moveSpeed, rb.linearVelocity.y, movement.z * moveSpeed);

        // Check if the player is grounded by casting a ray downwards from the groundCheck object's position.
        isGrounded = Physics.Raycast(groundCheck.transform.position, Vector3.down, 1.1f);

        // Rotate the player to face the movement direction if there is movement.
        if (movement != Vector3.zero) // Check if there is movement input.
        {
            Quaternion targetRotation = Quaternion.LookRotation(movement); // Calculate the rotation needed to face the movement direction.
            rb.rotation = Quaternion.Slerp(rb.rotation, targetRotation, Time.fixedDeltaTime * 10f); // Smoothly rotate the player towards the target direction.
        }
    }
}