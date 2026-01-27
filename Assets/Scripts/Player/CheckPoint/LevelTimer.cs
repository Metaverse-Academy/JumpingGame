using UnityEngine;
using UnityEngine.Events;

public class LevelTimer : MonoBehaviour
{
    [Header("Config (set later)")]
    [SerializeField] private float totalTimeSeconds = 60f; // set later
    [SerializeField] private bool startOnAwake = false;

    [Header("Runtime")]
    [SerializeField] private bool isRunning;
    [SerializeField] private float timeRemaining;

    public UnityEvent onTimerStart;
    public UnityEvent onTimerStop;
    public UnityEvent onTimerEnded;

    public float TotalTime => totalTimeSeconds;
    public float TimeRemaining => timeRemaining;
    public bool IsRunning => isRunning;

    // 1 = full time left, 0 = out of time
    public float NormalizedRemaining => (totalTimeSeconds <= 0f) ? 0f : Mathf.Clamp01(timeRemaining / totalTimeSeconds);

    private void Awake()
    {
        ResetTimer();
        if (startOnAwake) StartTimer();
    }

    private void Update()
    {
        if (!isRunning) return;

        timeRemaining -= Time.deltaTime;

        if (timeRemaining <= 0f)
        {
            timeRemaining = 0f;
            isRunning = false;
            onTimerEnded?.Invoke();
            onTimerStop?.Invoke();
        }
    }

    public void SetTotalTime(float seconds)
    {
        totalTimeSeconds = Mathf.Max(0f, seconds);
        ResetTimer();
    }

    public void ResetTimer()
    {
        timeRemaining = totalTimeSeconds;
    }

    public void StartTimer()
    {
        if (totalTimeSeconds <= 0f) return;
        if (isRunning) return;

        isRunning = true;
        onTimerStart?.Invoke();
    }

    public void StopTimer()
    {
        if (!isRunning) return;
        isRunning = false;
        onTimerStop?.Invoke();
    }
}
