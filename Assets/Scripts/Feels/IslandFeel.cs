using UnityEngine;

public class IslandFeel : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    float amplitude = 0.6f, duration = 20f;
    void Start()
    {
         LeanTween.moveY(gameObject, transform.position.y + amplitude, duration)
                 .setLoopPingPong()
                 .setEaseInOutSine();
    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
