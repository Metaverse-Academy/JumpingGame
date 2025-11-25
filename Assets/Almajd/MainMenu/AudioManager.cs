using UnityEngine;

public class AudioManager : MonoBehaviour
{
    public static AudioManager Instance;

    [Header("Audio Sources")]
    public AudioSource musicSource;
    public AudioSource sfxSource;

    [Header("Clips")]
    public AudioClip clickSound;

    [Header("Volumes")]
    [Range(0f, 1f)] public float musicVolume = 0.5f;
    [Range(0f, 1f)] public float sfxVolume = 1f;

    [Header("Fade Settings")]
    public float fadeDuration = 2f;

    float fadeTimer = 0f;

    void Awake()
    {
        if (Instance == null)
            Instance = this;
        else
            Destroy(gameObject);
    }

    void Start()
    {
        // Music fade-in
        musicSource.volume = 0f;
        musicSource.loop = true;
        musicSource.Play();
    }

    void Update()
    {
        // Fade music to target volume
        if (musicSource.volume < musicVolume)
        {
            fadeTimer += Time.deltaTime;
            float t = fadeTimer / fadeDuration;
            musicSource.volume = Mathf.Lerp(0f, musicVolume, t);
        }

        // Keep volumes controllable in real time
        sfxSource.volume = sfxVolume;
    }

    // ---------------- PUBLIC AUDIO CALLS ----------------
    public void PlayClick()
    {
        if (clickSound != null)
            sfxSource.PlayOneShot(clickSound, sfxVolume);
    }
}
