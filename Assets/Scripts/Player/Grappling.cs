using System;
using UnityEngine;
using UnityEngine.InputSystem;
using Unity.Cinemachine;

public class Grappling : MonoBehaviour
{
    private LineRenderer lr;

    private Vector3 grapplePoint;
    public LayerMask whatIsGrappleable;
    public Transform gunTip, player;
    [SerializeField]private float maxDistance = 12f;
    private SpringJoint joint;
    public PlayerInput playerInput;
    [SerializeField] public float jointSpring = 4.5f;
    [SerializeField] public float jointDamper = 7f;
    [SerializeField] public float jointMassScale = 4.5f;
    public CinemachineCamera defaultCamera;
    public static Grappling instance;
    public bool isGrappling;
    public AudioSource audioSource;

    // --- Added for movement while grappling ---
    private Rigidbody playerRb;
    float moveTarget = 0f;       // raw input from OnMove (y axis)
    float moveSmooth = 0f;       // smoothed input used for forces
    float moveSmoothVel = 0f;    // internal velocity for SmoothDamp
    [SerializeField] public float moveForce = 12f;      // how strong W / S pushes
    [SerializeField] public float inputSmoothTime = 0.08f; // smoothing time

    void Awake()
    {
        lr = GetComponent<LineRenderer>();
        playerInput = GetComponent<PlayerInput>();

        if (player != null)
            playerRb = player.GetComponent<Rigidbody>();
    }
    void Start()
    {
        instance = this;
    }

    public void OnGrapple(InputAction.CallbackContext context)
    {
        if (context.performed && !isGrappling)
        {
            StartGrapple();
        }
        else if (context.canceled)
        {
            isGrappling = false;
            StopGrapple();
        }
    }

    // --- InputSystem invoke method for move (Vector2). Use Move action -> Invoke Unity Event -> Grappling.OnMove ---
    public void OnMove(InputAction.CallbackContext ctx)
    {
        Vector2 v = ctx.ReadValue<Vector2>();
        // vertical is forward/back (W/S)
        moveTarget = v.y;
    }

    private void StopGrapple()
    {
        // cleanly release
        AudioMNG.instance.RopeSWing(0);
        isGrappling = false;
        lr.positionCount = 0;
        defaultCamera.Lens.FieldOfView = 90f;
        if (joint) Destroy(joint);
        // reset smoothed input
        moveTarget = 0f;
        moveSmooth = 0f;
    }

    private void StartGrapple()
    {
        // find ANY collider on the layer within radius around the player
        AudioMNG.instance.RopeSWing(1);
        AudioMNG.instance.PlaySounds(1);
        Collider[] hits = Physics.OverlapSphere(player.position, maxDistance, whatIsGrappleable, QueryTriggerInteraction.Ignore);
        if (hits == null || hits.Length == 0)
        {
            Debug.Log("No grapple target nearby on the selected layer.");
            return;
        }

        // just use the first one found (no closest logic)
        Collider box = hits[0];
        Debug.Log("Grapple target found: " + box.name);

        // anchor to the surface point closest to the player
        grapplePoint = box.ClosestPoint(player.position);

        // create swing joint
        joint = player.gameObject.AddComponent<SpringJoint>();
        joint.autoConfigureConnectedAnchor = false;
        joint.connectedAnchor = grapplePoint;

        float distanceFromPoint = Vector3.Distance(player.position, grapplePoint);
        float shortenFactor = 0.4f; // smaller = shorter rope, 0.4 = 40% of distance
        joint.maxDistance = distanceFromPoint * shortenFactor;
        joint.minDistance = distanceFromPoint * shortenFactor * 0.5f; // half of that for tension

        // spring settings (layer-only logic, no other checks)
        joint.spring = jointSpring;
        joint.damper = jointDamper;
        joint.massScale = jointMassScale;
        joint.enableCollision = true;

        lr.positionCount = 2;
        isGrappling = true;

        if (audioSource) audioSource.Play();
    }

    void LateUpdate()
    {
        DrawRope();
    }
    void DrawRope()
    {
        if (!joint) return;

        lr.SetPosition(0, gunTip.position);
        lr.SetPosition(1, grapplePoint);
    }

    void FixedUpdate()
    {
        // Only allow movement via W/S while grappling
        if (!isGrappling || joint == null || playerRb == null)
        {
            // smooth back to zero when not grappling
            moveSmooth = Mathf.SmoothDamp(moveSmooth, 0f, ref moveSmoothVel, inputSmoothTime);
            return;
        }

        // Smooth the input for nicer feel
        moveSmooth = Mathf.SmoothDamp(moveSmooth, moveTarget, ref moveSmoothVel, inputSmoothTime);

        if (Mathf.Abs(moveSmooth) > 0.01f)
        {
            // compute a forward direction that lies along the swing arc (player.forward projected on plane perpendicular to rope)
            Vector3 ropeDir = (grapplePoint - player.position).normalized;
            Vector3 forwardAlongArc = Vector3.ProjectOnPlane(player.forward, ropeDir).normalized;
            if (forwardAlongArc.sqrMagnitude < 0.001f)
            {
                // fallback if forward is nearly aligned with rope
                forwardAlongArc = Vector3.ProjectOnPlane(player.right, ropeDir).normalized;
            }

            // positive moveSmooth (W) -> forward force; negative (S) -> backward
            Vector3 force = forwardAlongArc * (moveSmooth * moveForce);

            // apply force at gun tip so torque feels natural
            playerRb.AddForceAtPosition(force, gunTip.position, ForceMode.Acceleration);

            // small tangential damping for smoothness (prevents jitter)
            Vector3 radialVel = Vector3.Project(playerRb.linearVelocity, ropeDir);
            Vector3 tangentialVel = playerRb.linearVelocity - radialVel;
            playerRb.AddForce(-tangentialVel * 0.12f, ForceMode.Acceleration);
        }
        else
        {
            // slight damping if no input to keep swing stable
            Vector3 ropeDir = (grapplePoint - player.position).normalized;
            Vector3 radialVel = Vector3.Project(playerRb.linearVelocity, ropeDir);
            Vector3 tangentialVel = playerRb.linearVelocity - radialVel;
            playerRb.AddForce(-tangentialVel * 0.05f, ForceMode.Acceleration);
        }
    }
}
