using NUnit.Framework;
using UnityEngine;
using UnityEngine.InputSystem;

public class HookingMechanic : MonoBehaviour
{
    [Header("Hook Path Settings")]
    [Tooltip("Assign the waypoints in order in the Inspector.")]
    public Transform[] points;
    public float moveSpeed = 5f;
    public float jumpForce = 20f;
    public float hookSearchRadius = 25f;

    [Header("Line")]
    [Tooltip("Optional: assign a LineRenderer in inspector or one will be created at runtime.")]
    public LineRenderer lineRenderer;
    public Color lineColor = new Color(0.72f, 0.53f, 0.043f, 1f); // dark yellow
    public float lineWidth = 0.04f;

    [Header("State Flags")]
    public bool isHooking { get; private set; }
    public bool isHooked { get; private set; }
    public static HookingMechanic instance;

    int index = 0;
    Vector3 target;
    Rigidbody rb;
    private bool showLine=false;

    void Awake() => rb = GetComponent<Rigidbody>();
    void OnEnable() => instance = this;

    void Start()
    {
         if (instance != null && instance != this)
        {
            Destroy(gameObject);
            return;
        }

        instance = this;
        // create a simple LineRenderer if none assigned
        if (lineRenderer == null)
        {
            lineRenderer = gameObject.AddComponent<LineRenderer>();
            lineRenderer.material = new Material(Shader.Find("Sprites/Default"));
        }
        lineRenderer.positionCount = 2;
        lineRenderer.useWorldSpace = true;
        lineRenderer.startWidth = lineWidth;
        lineRenderer.endWidth = lineWidth;
        lineRenderer.numCapVertices = 4;
        lineRenderer.enabled = false;
        lineRenderer.startColor = lineColor;
        lineRenderer.endColor = lineColor;
    }
    // Called by PlayerInput when the Hook action is triggered
    public void OnHook(InputAction.CallbackContext context)
    {
        if (!context.performed || isHooking) return;

        int nearestIndex = FindNearestHookIndex();
        if (nearestIndex == -1) return;

        index = nearestIndex;
        target = points[index].position;
        isHooked = false;
        isHooking = true;
        showLine = true;
        if (lineRenderer != null) lineRenderer.enabled = true;
    }

    // Called by PlayerInput when the HookJump action is triggered
    public void OnHookJump(InputAction.CallbackContext context)
    {
        if (!context.performed || !isHooked || isHooking) return;

        int nearestIndex = FindNearestHookIndex();
        if (nearestIndex == -1)
        {
            isHooked = false;
            return;
        }

        index = nearestIndex;
        target = points[index].position;
        isHooked = false;
        isHooking = true;
        if (lineRenderer != null) lineRenderer.enabled = true;
    }
     public void SetHookPoints(Transform[] newPoints)
    {
        points = newPoints;
        index = 0;
        isHooking = false;
        isHooked = false;
        showLine = false;

        // just to be safe
        if (lineRenderer != null)
        {
            //lineRenderer.enabled = false;
        }
    }


    int FindNearestHookIndex()
    {
        if (points == null || points.Length == 0) return -1;

        Vector3 origin = transform.position;
        float maxSqrDistance = hookSearchRadius > 0f
            ? hookSearchRadius * hookSearchRadius
            : float.PositiveInfinity;
        float bestSqrDistance = maxSqrDistance;
        int bestIndex = -1;

        for (int i = 0; i < points.Length; i++)
        {
            Transform hookPoint = points[i];
            if (hookPoint == null) continue;

            float sqrDistance = (hookPoint.position - origin).sqrMagnitude;
            if (sqrDistance < bestSqrDistance)
            {
                bestSqrDistance = sqrDistance;
                bestIndex = i;
            }
        }

        return bestIndex;
    }

    void Update()
    {
         if (!isHooking) return;
       
    }

    void LateUpdate()
    {
        // update line positions when hooking or hooked
        if (lineRenderer == null) return;
        if (!showLine)
        {
            lineRenderer.enabled = true;
            lineRenderer.SetPosition(0, transform.position);
            lineRenderer.SetPosition(1, target);
            
        }
        else
        {
            lineRenderer.enabled = false;
         
        }
    }
    void FixedUpdate()
    {
        if (!isHooking) return;

        Vector3 toTarget = target - transform.position;
        float distance = toTarget.magnitude;

        if (distance <= 1.5f)
        {
            isHooking = false;
            isHooked = true;
            index++;

            if (rb != null)
            {
                rb.linearVelocity = Vector3.zero;
                rb.angularVelocity = Vector3.zero;
                rb.AddForce(Vector3.up * jumpForce, ForceMode.Impulse);
                  if (lineRenderer != null) lineRenderer.enabled = false;
            }
            // keep showing line when hooked; LateUpdate will handle it
            return;
        }

        if (rb != null)
        {
            Vector3 direction = toTarget / distance;
            rb.linearVelocity = direction * moveSpeed;
        }
    }

    // Optional: call this to fully reset hook state externally
    public void ResetHookState()
    {
        isHooked = false;
        isHooking = false;
        index = 0;
      
    }
}
