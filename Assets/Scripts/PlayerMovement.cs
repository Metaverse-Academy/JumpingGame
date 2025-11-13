using System.Collections;
using System.Runtime.InteropServices;
using MoreMountains.Feedbacks;
using MoreMountains.Tools;
using UnityEngine; // Import the UnityEngine namespace to access Unity-specific classes and functions.
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement; // Import the InputSystem namespace to use the new Input System.

public class PlayerMovement : MonoBehaviour
{
    // Reference to the Rigidbody component attached to the player.
    private Rigidbody rb;

    // Movement speed of the player.
    [SerializeField] private MMF_Player jumpFeedback;
    [SerializeField]private Transform ReSpawnPos; 

    public float moveSpeed = 5f;

    // Force applied for jumping.
    public float jumpForce = 5f;

    // Boolean to check if the player is grounded.
    public bool isGrounded;

private bool Iswalking;
    // Variable to store movement input.
    private Vector2 movementInput;
    public GameObject groundCheck;
    public WallRunning wallRunning;
    public Transform cam;
    public Animator animator;
    private bool pushed = false;
    public bool ISPlayerJumpFromWall = false;

    // --- Soft fall fields ---
    [Header("Fall / Soft Landing")]
    [Range(0f, 3f)]
    public float fallGravityScale = 0.45f; // 1 = normal gravity, 0 = no gravity while falling
    public float fallVelocityThreshold = -0.1f; // apply when downward velocity < this
    private bool inWallMovement;

    void Start()
    {

        wallRunning = GetComponent<WallRunning>();
        // Get the Rigidbody component attached to this GameObject.
        rb = GetComponent<Rigidbody>();
        if (cam == null && Camera.main != null)
        {
            cam = Camera.main.transform;
        }
    }
    void Update()
    {
        isGrounded = Physics.Raycast(groundCheck.transform.position, Vector3.down, 2f);
        Debug.DrawRay(groundCheck.transform.position, Vector3.down* 2, Color.red);
        Debug.Log(isGrounded);

        // if (isGrounded)
        // {

        //     ISPlayerJumpFromWall = false;

        // }

        animator.SetBool("IsWalking",Iswalking);
        if (isGrounded == true && Iswalking == true)
        {

            AudioMNG.instance.Walking(1);


        }
        else {            
            AudioMNG.instance.Walking(0); 
 }

    }
    // This method is called by the Input System when the "Move" action is triggered.
    public void OnMove(InputAction.CallbackContext context)
    {
        if (context.performed ) {
            Iswalking = true;
        
        }

        movementInput = context.ReadValue<Vector2>();

        if (context.canceled ) {
            Iswalking = false;
            animator.SetTrigger("StopWalking");

        }

       // moveSpeed = Mathf.Lerp(0f, moveSpeed, 1f * Time.fixedDeltaTime); 
    }

    // This method is called by the Input System when the "Jump" action is triggered.
    public void OnJump(InputAction.CallbackContext context)
    {

        if (context.started && Iswalking == true)
        {
            animator.SetTrigger("StopWalking");

        }

        if (context.performed && isGrounded)
        {        
            AudioMNG.instance.PlaySounds(2);
            if (wallRunning.isWallRunning) return;
            AudioMNG.instance.PlaySounds(2);
            // Apply an upward force to the Rigidbody for jumping.
            jumpFeedback.PlayFeedbacks();
            rb.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);
            animator.SetTrigger("Jump");
        }
    }

    // FixedUpdate is called at a fixed time interval and is used for physics calculations.
    void FixedUpdate()
    {
bool hookActive = HookingMechanic.instance != null &&
                          HookingMechanic.instance.isHooking;
        if (hookActive)
        {
            animator.SetFloat("Speed", 0f);
            return;
        }
        // -- Soft fall: reduce gravity while falling unless grappling or wallrunning or grounded --
        bool grapplingActive = (Grappling.instance != null && Grappling.instance.isGrappling);
        if (rb != null && !grapplingActive && !wallRunning.isWallRunning && !isGrounded)
        {
            if (rb.linearVelocity.y < fallVelocityThreshold)
            {
                // Compute anti-gravity so net gravity becomes `fallGravityScale * Physics.gravity`
                Vector3 antiGravity = -Physics.gravity * (1f - fallGravityScale);
                rb.AddForce(antiGravity, ForceMode.Acceleration);
            }
        }

        if (wallRunning.isWallRunning) return;
        if (movementInput.y < 0)
        {
            
        }

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
        if (Grappling.instance != null && Grappling.instance.isGrappling == true) return;
        if (ISPlayerJumpFromWall ==false)
        {

            rb.linearVelocity = new Vector3(movement.x * moveSpeed, rb.linearVelocity.y, movement.z * moveSpeed);
        }
        animator.SetBool("IsGrounded", isGrounded); 
        if (movement != Vector3.zero)
        {
            Quaternion targetRotation = Quaternion.LookRotation(movement);
            rb.rotation = Quaternion.Slerp(rb.rotation, targetRotation, Time.fixedDeltaTime * 10f);
        }
    }

   public void ReLoad()
    {
        transform.position = ReSpawnPos.position;



    }


    void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Goal"))
        {
            SceneManager.LoadScene("Prototype1");
        }
    }
   
   

}
