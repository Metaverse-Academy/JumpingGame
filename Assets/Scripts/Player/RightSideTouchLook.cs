using UnityEngine;
using UnityEngine.InputSystem;
using Unity.Cinemachine;

public class RightSideTouchLook : MonoBehaviour
{
    [Header("References")]
    [SerializeField] private CinemachineOrbitalFollow orbitalFollow;

    [Header("Touch Area")]
    [Range(0f, 1f)]
    [SerializeField] private float rightSideStart = 0.5f;

    [Header("Tuning")]
    [SerializeField] private float sensitivity = 0.1f;
    [SerializeField] private bool invertY = true;

    private int activeFingerId = -1;
    private Vector2 lastPos;
    private bool hasFinger;

    private void Awake()
    {
        if (!orbitalFollow)
        {
            orbitalFollow = GetComponent<CinemachineOrbitalFollow>();
        }
    }

    private void Update()
    {
        if (orbitalFollow == null || Touchscreen.current == null)
        {
            return;
        }

        if (!hasFinger)
        {
            TryAcquireFinger();
        }

        if (hasFinger)
        {
            UpdateActiveFinger();
        }

#if UNITY_EDITOR || UNITY_STANDALONE
        ApplyMouseLook();
#endif
    }

    private void TryAcquireFinger()
    {
        foreach (var touch in Touchscreen.current.touches)
        {
            if (!touch.press.isPressed)
            {
                continue;
            }

            Vector2 pos = touch.position.ReadValue();
            if (pos.x < Screen.width * rightSideStart)
            {
                continue;
            }

            activeFingerId = touch.touchId.ReadValue();
            lastPos = pos;
            hasFinger = true;
            break;
        }
    }

    private void UpdateActiveFinger()
    {
        bool stillDown = false;

        foreach (var touch in Touchscreen.current.touches)
        {
            if (touch.touchId.ReadValue() != activeFingerId)
            {
                continue;
            }

            if (!touch.press.isPressed)
            {
                break;
            }

            Vector2 pos = touch.position.ReadValue();
            Vector2 delta = pos - lastPos;
            lastPos = pos;

            ApplyDelta(delta);
            stillDown = true;
            break;
        }

        if (!stillDown)
        {
            hasFinger = false;
            activeFingerId = -1;
        }
    }

    private void ApplyDelta(Vector2 delta)
    {
        if (delta.sqrMagnitude < 0.0001f)
        {
            return;
        }

        float dx = delta.x * sensitivity;
        float dy = delta.y * sensitivity;
        if (invertY)
        {
            dy = -dy;
        }

        orbitalFollow.HorizontalAxis.Value += dx;
        orbitalFollow.VerticalAxis.Value += dy;
    }

#if UNITY_EDITOR || UNITY_STANDALONE
    private void ApplyMouseLook()
    {
        if (Mouse.current == null || !Mouse.current.rightButton.isPressed)
        {
            return;
        }

        Vector2 pos = Mouse.current.position.ReadValue();
        if (pos.x < Screen.width * rightSideStart)
        {
            return;
        }

        ApplyDelta(Mouse.current.delta.ReadValue());
    }
#endif
}
