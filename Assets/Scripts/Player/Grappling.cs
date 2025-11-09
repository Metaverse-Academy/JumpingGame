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
    private float maxDistance = 28f;
    private SpringJoint joint;
    public PlayerInput playerInput;
    [SerializeField] public float jointSpring = 4.5f;
    [SerializeField] public float jointDamper = 7f;
    [SerializeField] public float jointMassScale = 4.5f;
    public CinemachineCamera defaultCamera;
    public static Grappling instance;
    public bool isGrappling;
    public AudioSource audioSource;

    void Awake()
    {
        lr = GetComponent<LineRenderer>();
        playerInput = GetComponent<PlayerInput>();
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

    private void StopGrapple()
    {
        // cleanly release
        AudioMNG.instance.RopeSWing(0);
        isGrappling = false;
        lr.positionCount = 0;
        defaultCamera.Lens.FieldOfView = 90f;
        if (joint) Destroy(joint);
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
        joint.maxDistance = distanceFromPoint * 0.8f;   // some slack
        joint.minDistance = distanceFromPoint * 0.25f;  // min rope length

        // spring settings (layer-only logic, no other checks)
        joint.spring = jointSpring;
        joint.damper = jointDamper;
        joint.massScale = jointMassScale;
        joint.enableCollision = true;

        lr.positionCount = 2;
        isGrappling = true;
       
        if (audioSource) audioSource.Play();
    }
    // private void StartGrapple()
    // {
    //     if (Physics.Raycast(mainCamera.position, mainCamera.forward, out RaycastHit hit, maxDistance, whatIsGrappleable))
    //     {
    //         Debug.Log("Grapple hit: " + hit.collider.name);
    //         grapplePoint = hit.point;
    //         joint = player.gameObject.AddComponent<SpringJoint>();
    //         joint.autoConfigureConnectedAnchor = false;
    //         joint.connectedAnchor = grapplePoint;

    //         float distanceFromPoint = Vector3.Distance(player.position, grapplePoint);

    //         //The distance grapple will try to keep from grapple point. 
    //         joint.maxDistance = distanceFromPoint * 0.8f;
    //         joint.minDistance = distanceFromPoint * 0.25f;

    //         //Adjust these values to fit your game.
    //         joint.spring = jointSpring;
    //         joint.damper = jointDamper;
    //         joint.massScale = jointMassScale;

    //         lr.positionCount = 2;
    //         isGrappling = true;
    //         audioSource.Play();
    //     }
    // }
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
