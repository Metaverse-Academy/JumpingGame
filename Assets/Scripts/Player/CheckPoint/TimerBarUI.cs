using UnityEngine;
using UnityEngine.UI;
using TMPro;

public class TimerBarUI : MonoBehaviour
{
    [Header("Refs")]
    [SerializeField] private LevelTimer timer;
    [SerializeField] private Slider slider;
    [SerializeField] private Image fillImage;
    [SerializeField] private TMP_Text timeText; // optional

    [Header("Color thresholds (by remaining %)")]
    [Range(0f, 1f)] public float goodThreshold = 0.6f;   // above this = good
    [Range(0f, 1f)] public float warnThreshold = 0.25f;  // between warn and good = warning, below warn = danger

    [Header("Colors")]
    public Color goodColor = Color.green;
    public Color warnColor = new Color(1f, 0.65f, 0f); // orange-ish
    public Color dangerColor = Color.red;

    private void Reset()
    {
        slider = GetComponentInChildren<Slider>();
    }

    private void Update()
    {
        if (timer == null || slider == null) return;

        float t = timer.NormalizedRemaining; // 1..0
        slider.value = t;

        if (fillImage != null)
        {
            if (t >= goodThreshold) fillImage.color = goodColor;
            else if (t >= warnThreshold) fillImage.color = warnColor;
            else fillImage.color = dangerColor;
        }

        if (timeText != null)
            timeText.text = FormatTime(timer.TimeRemaining);
    }

    private static string FormatTime(float seconds)
    {
        seconds = Mathf.Max(0f, seconds);
        int s = Mathf.FloorToInt(seconds);
        int m = s / 60;
        s = s % 60;
        return $"{m:00}:{s:00}";
    }
}
