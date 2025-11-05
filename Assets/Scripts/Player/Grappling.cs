using System;
using UnityEngine;
using UnityEngine.InputSystem;

public class Grappling : MonoBehaviour
{
     private LineRenderer lr;
    private Vector3 grapplePoint;
    public LayerMask whatIsGrappleable;
    public Transform gunTip, mainCamera, player;
    private float maxDistance = 100f;
    private SpringJoint joint;
    public PlayerInput playerInput;
    [SerializeField] public float jointSpring = 4.5f;
    [SerializeField] public float jointDamper = 7f;
    [SerializeField] public float jointMassScale = 4.5f;
    private bool isGrappling;
    public AudioSource audioSource;

    void Awake()
    {
        lr = GetComponent<LineRenderer>();
        playerInput = GetComponent<PlayerInput>();
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

    private void StopGrapple()
    {
        lr.positionCount = 0;
        Destroy(joint);
    }

    private void StartGrapple()
    {
        if (Physics.Raycast(mainCamera.position, mainCamera.forward, out RaycastHit hit, maxDistance, whatIsGrappleable))
        {
            Debug.Log("Grapple hit: " + hit.collider.name);
            grapplePoint = hit.point;
            joint = player.gameObject.AddComponent<SpringJoint>();
            joint.autoConfigureConnectedAnchor = false;
            joint.connectedAnchor = grapplePoint;

            float distanceFromPoint = Vector3.Distance(player.position, grapplePoint);

            //The distance grapple will try to keep from grapple point. 
            joint.maxDistance = distanceFromPoint * 0.8f;
            joint.minDistance = distanceFromPoint * 0.25f;

            //Adjust these values to fit your game.
            joint.spring = jointSpring;
            joint.damper = jointDamper;
            joint.massScale = jointMassScale;

            lr.positionCount = 2;
            isGrappling = true;
            audioSource.Play();
        }
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
}
