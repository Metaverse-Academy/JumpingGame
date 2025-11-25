using UnityEngine;
using UnityEngine.SceneManagement;
using System.Collections;

public class LevelTransitionTrigger : MonoBehaviour
{
    [Header("Scene Names")]
    [SerializeField] private string currentLevelName;  // e.g. "Level1"
    [SerializeField] private string nextLevelName;     // e.g. "Level2"

    [Header("Player Detection")]
    [SerializeField] private string playerTag = "Player";

    private bool isTransitioning = false;

    private void OnTriggerEnter(Collider other)
    {
        if (isTransitioning) return;

        if (other.CompareTag(playerTag))
        {
            StartCoroutine(TransitionToNextLevel());
           // PlayerCheckpoint.instance.SetCheckpoint(transform);
        }
    }

    private IEnumerator TransitionToNextLevel()
    {
        isTransitioning = true;

        // 1) Load next level additively
        AsyncOperation asyncLoad = SceneManager.LoadSceneAsync(nextLevelName, LoadSceneMode.Additive);

        while (!asyncLoad.isDone)
        {
            // Optionally, show loading progress here: asyncLoad.progress
            yield return null;
        }

        // 2) Make next level active
        Scene nextScene = SceneManager.GetSceneByName(nextLevelName);
        SceneManager.SetActiveScene(nextScene);

        // 3) Unload current level (but not the Persistent scene!)
        // AsyncOperation asyncUnload = SceneManager.UnloadSceneAsync(currentLevelName);

        // while (!asyncUnload.isDone)
        // {
        //     yield return null;
        // }

        isTransitioning = false;
    }
}
