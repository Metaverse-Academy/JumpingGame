using UnityEngine;
using UnityEngine.EventSystems;
using UnityEngine.SceneManagement;
using System.Collections;

public class MainMenu : MonoBehaviour, IPointerEnterHandler, IPointerExitHandler, IPointerClickHandler
{
    [Header("Scale Settings")]
    public float hoverScale = 1.1f;
    public float clickScale = 0.9f;
    public float animationSpeed = 10f;

    [Header("Main Menu Settings")]
    public CanvasGroup creditsPanel;  // Assign Credits panel CanvasGroup
    public string sceneToLoad;        // Assign gameplay scene name

    [Header("Audio")]
    public AudioManager audioManager; // Assign AudioManager reference

    [Header("Scene Transition")]
    public CanvasGroup fadeOverlay;   // Full-screen black overlay
    public float fadeDuration = 0.5f; // seconds

    private Vector3 normalScale;
    private Vector3 targetScale;

    void Start()
    {
        normalScale = transform.localScale;
        targetScale = normalScale;

        // Initialize Credits panel
        if (creditsPanel != null)
        {
            creditsPanel.alpha = 0f;
            creditsPanel.interactable = false;
            creditsPanel.blocksRaycasts = false;
        }

        // Initialize Fade overlay
        if (fadeOverlay != null)
        {
            fadeOverlay.alpha = 0f;
            fadeOverlay.interactable = false;
            fadeOverlay.blocksRaycasts = false;
        }
    }

    void Update()
    {
        // Smoothly move to target scale
        transform.localScale = Vector3.Lerp(transform.localScale, targetScale, Time.deltaTime * animationSpeed);
    }

    // ---------------- Hover ----------------
    public void OnPointerEnter(PointerEventData eventData)
    {
        targetScale = normalScale * hoverScale;
    }

    public void OnPointerExit(PointerEventData eventData)
    {
        targetScale = normalScale;
    }

    // ---------------- Click ----------------
    public void OnPointerClick(PointerEventData eventData)
    {
        if (audioManager != null) audioManager.PlayClick();
        StartCoroutine(ClickAnimation());
    }

    private IEnumerator ClickAnimation()
    {
        Vector3 originalTarget = targetScale;
        targetScale = normalScale * clickScale;

        yield return new WaitForSeconds(0.1f);

        targetScale = originalTarget;
    }

    // ---------------- Button Actions ----------------
    public void Play()
    {
        StartCoroutine(FadeOutAndLoadScene());
    }

    public void OpenCredits()
    {
        if (creditsPanel != null)
        {
            creditsPanel.interactable = true;
            creditsPanel.blocksRaycasts = true;
            StartCoroutine(FadeCanvasGroup(creditsPanel, 0.8f, 0.3f));
        }
    }

    public void CloseCredits()
    {
        if (creditsPanel != null)
        {
            StartCoroutine(FadeOutCanvasGroup(creditsPanel, 0.3f));
        }
    }

    public void Quit()
    {
        Application.Quit();
    }

    // ---------------- Fade Scene Transition ----------------
    private IEnumerator FadeOutAndLoadScene()
    {
        // Shrink & grow button animation
        StartCoroutine(ClickAnimation());

        float time = 0f;
        float startVolume = 1f;
        if (audioManager != null && audioManager.musicSource != null)
            startVolume = audioManager.musicSource.volume;

        while (time < fadeDuration)
        {
            time += Time.deltaTime;
            float t = time / fadeDuration;

            // Fade black overlay
            if (fadeOverlay != null)
                fadeOverlay.alpha = Mathf.Lerp(0f, 1f, t);

            // Fade music
            if (audioManager != null && audioManager.musicSource != null)
                audioManager.musicSource.volume = Mathf.Lerp(startVolume, 0f, t);

            yield return null;
        }

        if (fadeOverlay != null)
            fadeOverlay.alpha = 1f;

        if (audioManager != null && audioManager.musicSource != null)
            audioManager.musicSource.volume = 0f;

        // Load the scene
        if (!string.IsNullOrEmpty(sceneToLoad))
            SceneManager.LoadScene(sceneToLoad);
        else
            Debug.LogError("SceneToLoad not set in MainMenu!");
    }

    // ---------------- Panel Fade ----------------
    private IEnumerator FadeCanvasGroup(CanvasGroup cg, float targetAlpha, float duration)
    {
        float start = cg.alpha;
        float time = 0f;
        while (time < duration)
        {
            time += Time.deltaTime;
            cg.alpha = Mathf.Lerp(start, targetAlpha, time / duration);
            yield return null;
        }
        cg.alpha = targetAlpha;
    }

    private IEnumerator FadeOutCanvasGroup(CanvasGroup cg, float duration)
    {
        yield return FadeCanvasGroup(cg, 0f, duration);
        cg.interactable = false;
        cg.blocksRaycasts = false;
    }
}
