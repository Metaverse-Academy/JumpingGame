using UnityEngine;
using UnityEngine.EventSystems;
using Unity.Cinemachine;

public class RightSideOrbitalLook : MonoBehaviour, IPointerDownHandler, IPointerUpHandler, IDragHandler
{
    [Header("Cinemachine")]
    [SerializeField] private CinemachineCamera cmCamera;

    [Header("Tuning")]
    [SerializeField] private float sensitivity = 0.15f;   // degrees per pixel (tune)
    [SerializeField] private bool invertY = false;
    [SerializeField] private float deadzonePixels = 1.5f;

    private CinemachineOrbitalFollow _orbital;
    private bool _active;
    private Vector2 _lastPos;

    private void Awake()
    {
        if (!cmCamera) cmCamera = GetComponentInParent<CinemachineCamera>();
        if (cmCamera) _orbital = cmCamera.GetComponent<CinemachineOrbitalFollow>();

        if (!_orbital)
            Debug.LogError("RightSideOrbitalLook: CinemachineOrbitalFollow not found on the CinemachineCamera.");
    }

    public void OnPointerDown(PointerEventData eventData)
    {
        _active = true;
        _lastPos = eventData.position;
    }

    public void OnDrag(PointerEventData eventData)
    {
        if (!_active || _orbital == null) return;

        Vector2 pos = eventData.position;
        Vector2 delta = pos - _lastPos;
        _lastPos = pos;

        if (delta.sqrMagnitude < deadzonePixels * deadzonePixels)
            return;

        float yawDelta = delta.x * sensitivity;
        float pitchDelta = delta.y * sensitivity * (invertY ? 1f : -1f);

        // Orbital Follow axes are in degrees (horizontal + vertical)
        _orbital.HorizontalAxis.Value += yawDelta;
        _orbital.VerticalAxis.Value += pitchDelta;

        // Optional: clamp manually (recommended if your VerticalAxis range is limited)
        // Use the axis Range values set in the OrbitalFollow inspector.
        var vRange = _orbital.VerticalAxis.Range;
        _orbital.VerticalAxis.Value = Mathf.Clamp(_orbital.VerticalAxis.Value, vRange.x, vRange.y);

        // Horizontal usually wraps, so clamp is often unnecessary.
        // If you DON'T want wrap, clamp it like vertical:
        // var hRange = _orbital.HorizontalAxis.Range;
        // _orbital.HorizontalAxis.Value = Mathf.Clamp(_orbital.HorizontalAxis.Value, hRange.Min, hRange.Max);
    }

    public void OnPointerUp(PointerEventData eventData)
    {
        _active = false;
    }
}
