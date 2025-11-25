using UnityEngine;
using TMPro;
using UnityEngine.UI;
using System.Collections;

public class TypewriterIntro : MonoBehaviour
{
    [Header("UI")]
    public TextMeshProUGUI storyText;
    public Image fadePanel;

    [Header("Settings")]
    public float typeSpeed = 0.03f;
    public float delayAfterTyping = 2f;
    public float fadeSpeed = 1.2f;
    [TextArea]
    public string fullText;

    private PlayerMovement player;

    void Start()
    {
        // Find player automatically
        player = Object.FindFirstObjectByType<PlayerMovement>();
        if (player != null)
            player.enabled = false;

        // Start black, then type
        StartCoroutine(TypeRoutine());
    }

    IEnumerator TypeRoutine()
    {
        storyText.text = "";

        // Reveal text 1 letter at a time
        foreach (char c in fullText)
        {
            storyText.text += c;
            yield return new WaitForSeconds(typeSpeed);
        }

        // Pause before fading
        yield return new WaitForSeconds(delayAfterTyping);

        StartCoroutine(FadeOutRoutine());
    }

    IEnumerator FadeOutRoutine()
    {
        Color c = fadePanel.color;

        while (c.a > 0f)
        {
            c.a -= Time.deltaTime * fadeSpeed;
            fadePanel.color = c;
            yield return null;
        }

        // Restore player control
        if (player != null)
            player.enabled = true;

        // Disable UI
        gameObject.SetActive(false);
    }
}

