using UnityEngine;

public class Performance : MonoBehaviour
{
     [SerializeField] private int targetFps = 60;
    [SerializeField] private bool disableVSync = true;

    private void Awake()
    {
        // If vSync is enabled, it can override Application.targetFrameRate.
        QualitySettings.vSyncCount = disableVSync ? 0 : 1;

        Application.targetFrameRate = targetFps;

        // Helps keep consistent behavior when app loses focus / resumes
        Application.runInBackground = true;
    }
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
