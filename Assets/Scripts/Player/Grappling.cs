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

    void Awake()
    {
        lr = GetComponent<LineRenderer>();
        playerInput = GetComponent<PlayerInput>();
    }
    
    public void OnGrapple(InputAction.CallbackContext context)
    {
        if (context.performed)
        {
            StartGrapple();
        }
        else if (context.canceled)
        {
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
