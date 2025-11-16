using System;
using UnityEngine;
using UnityEngine.InputSystem;
using Unity.Cinemachine;
using System.Collections;

public class Grappling : MonoBehaviour
{
    private LineRenderer lr;
    private Vector3 grapplePoint;
    public LayerMask whatIsGrappleable;
    public Transform gunTip, player;
    [SerializeField] private float maxDistance = 12f;
    public bool zeroVelocityOnStart = true;
    private SpringJoint joint;
    public PlayerInput playerInput;
    [SerializeField] public float jointSpring = 4.5f;
    [SerializeField] public float jointDamper = 7f;
    [SerializeField] public float jointMassScale = 4.5f;
    public CinemachineCamera defaultCamera;
    public static Grappling instance;
    public bool isGrappling;
    public AudioSource audioSource;

    [Header("References")]
    public Transform cameraTransform;

    private Rigidbody playerRb;
    float moveTarget = 0f;
    float moveSmooth = 0f;
    float moveSmoothVel = 0f;
    [SerializeField] public float moveForce = 12f;
    [SerializeField] public float inputSmoothTime = 0.08f;

    [Header("Swing Settings")]
    public float swingForce = 25f;
    public bool autoSwingToTarget = true;

    [Header("Auto Release Settings")]
    public float swingTime = 1.2f;
    public float launchBoost = 8f;

    void Awake()
    {
        lr = GetComponent<LineRenderer>();
        playerInput = GetComponent<PlayerInput>();
        if (player != null)
            playerRb = player.GetComponent<Rigidbody>();
    }

    void Start()
    {
        StartCoroutine(IntitializeGrapple());
        instance = this;
    }

    private IEnumerator IntitializeGrapple()
    {
        lr.enabled = false;
        joint = player.gameObject.AddComponent<SpringJoint>();
        yield return new WaitForSeconds(0.1f);
        if (joint) Destroy(joint);
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

    public void OnMove(InputAction.CallbackContext ctx)
    {
        Vector2 v = ctx.ReadValue<Vector2>();
        moveTarget = v.y;
    }

    private void StopGrapple()
    {
        AudioMNG.instance.RopeSWing(0);
        isGrappling = false;
        lr.positionCount = 0;
        defaultCamera.Lens.FieldOfView = 90f;
        if (joint) Destroy(joint);
        moveTarget = 0f;
        moveSmooth = 0f;
    }

    private void StartGrapple()
    {
        if (!lr.enabled)
            lr.enabled = true;

        StartCoroutine(CheckGrappling());
    }

    IEnumerator CheckGrappling()
    {
        Collider[] hits = Physics.OverlapSphere(player.position, maxDistance, whatIsGrappleable, QueryTriggerInteraction.Ignore);
        if (hits == null || hits.Length == 0)
        {
            Debug.Log("No grapple target nearby on the selected layer.");
            yield break;
        }

        Collider box = hits[0];
        grapplePoint = box.ClosestPoint(player.position);
        AudioMNG.instance.RopeSWing(1);
        AudioMNG.instance.PlaySounds(1);

        joint = player.gameObject.AddComponent<SpringJoint>();
        joint.autoConfigureConnectedAnchor = false;
        joint.connectedAnchor = grapplePoint;
        yield return new WaitForFixedUpdate();

        float distanceFromPoint = Vector3.Distance(player.position, grapplePoint);
        float shortenFactor = 0.8f;
        joint.maxDistance = distanceFromPoint * shortenFactor;
        joint.minDistance = distanceFromPoint * shortenFactor * 0.5f;

        joint.spring = jointSpring;
        joint.damper = jointDamper;
        joint.massScale = jointMassScale;
        joint.enableCollision = true;

        lr.positionCount = 2;
        isGrappling = true;

        moveTarget = 0f;
        moveSmooth = 0f;
        moveSmoothVel = 0f;

        if (zeroVelocityOnStart && playerRb != null)
        {
            playerRb.linearVelocity = Vector3.zero;
            playerRb.angularVelocity = Vector3.zero;
        }

        if (autoSwingToTarget && cameraTransform != null)
        {
            Vector3 grappleDir = (grapplePoint - player.position).normalized;
            Vector3 cameraDir = cameraTransform.forward;
            Vector3 swingDir = Vector3.Cross(grappleDir, Vector3.Cross(cameraDir, grappleDir)).normalized;
            playerRb.AddForce(swingDir * swingForce, ForceMode.VelocityChange);
            StartCoroutine(AutoReleaseGrapple());
        }

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
        if (!isGrappling || joint == null || playerRb == null)
        {
            moveSmooth = Mathf.SmoothDamp(moveSmooth, 0f, ref moveSmoothVel, inputSmoothTime);
            return;
        }

        if (!autoSwingToTarget && Mathf.Abs(moveSmooth) > 0.01f)
        {
            Vector3 ropeDir = (grapplePoint - player.position).normalized;
            Vector3 aimForward = cameraTransform != null ? cameraTransform.forward : player.forward;
            Vector3 aimRight = cameraTransform != null ? cameraTransform.right : player.right;

            Vector3 forwardAlongArc = Vector3.ProjectOnPlane(aimForward, ropeDir).normalized;
            if (forwardAlongArc.sqrMagnitude < 0.001f)
            {
                forwardAlongArc = Vector3.ProjectOnPlane(aimRight, ropeDir).normalized;
            }

            Vector3 force = forwardAlongArc * (moveSmooth * moveForce);
            playerRb.AddForceAtPosition(force, gunTip.position, ForceMode.Acceleration);

            Vector3 radialVel = Vector3.Project(playerRb.linearVelocity, ropeDir);
            Vector3 tangentialVel = playerRb.linearVelocity - radialVel;
            playerRb.AddForce(-tangentialVel * 0.12f, ForceMode.Acceleration);
        }
        else
        {
            Vector3 ropeDir = (grapplePoint - player.position).normalized;
            Vector3 radialVel = Vector3.Project(playerRb.linearVelocity, ropeDir);
            Vector3 tangentialVel = playerRb.linearVelocity - radialVel;
            playerRb.AddForce(-tangentialVel * 0.05f, ForceMode.Acceleration);
        }
    }

    private IEnumerator AutoReleaseGrapple()
    {
        yield return new WaitForSeconds(swingTime);

        if (!isGrappling || joint == null || playerRb == null)
            yield break;

        Vector3 exitVelocity = playerRb.linearVelocity;
        StopGrapple();

        Vector3 forwardDir = cameraTransform.forward;
        playerRb.AddForce(forwardDir * launchBoost, ForceMode.VelocityChange);
    }
}
