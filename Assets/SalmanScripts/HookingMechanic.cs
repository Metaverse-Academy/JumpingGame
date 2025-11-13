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

    [Header("State Flags")]
    public bool isHooking { get; private set; }
    public bool isHooked { get; private set; }
    public static HookingMechanic instance;

    int index = 0;
    Vector3 target;
    Rigidbody rb;

    void Awake() => rb = GetComponent<Rigidbody>();
    void OnEnable() => instance = this;
    // Called by PlayerInput when the Hook action is triggered
    public void OnHook(InputAction.CallbackContext context)
    {
        if (!context.performed || isHooking) return;
        if (points == null || index >= points.Length) return;

        target = points[index].position;
        isHooked = false;
        isHooking = true;
    }

    // Called by PlayerInput when the HookJump action is triggered
    public void OnHookJump(InputAction.CallbackContext context)
    {
        if (!context.performed || !isHooked || isHooking) return;

        if (points == null || index >= points.Length)
        {
            isHooked = false;
            return;
        }

        target = points[index].position;
        isHooked = false;
        isHooking = true;
    }

    void Update()
    {
         if (!isHooking) return;
       
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
            }
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