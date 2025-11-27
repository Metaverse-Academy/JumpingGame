using UnityEngine;


public class MakePersistent : MonoBehaviour
{
    private void Awake()
    {
        DontDestroyOnLoad(gameObject); // this GameObject + all children persist
    }
}