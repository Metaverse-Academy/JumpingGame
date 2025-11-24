using UnityEngine;

public class GrappleFeel : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    float amplitude = 0.6f, duration = 2f;
    void Start()
    {
        LeanTween.moveY(gameObject, transform.position.y + amplitude, duration)
                 .setLoopPingPong()
                 .setEaseInOutSine();
       LeanTween.moveX(gameObject, transform.position.x + amplitude, duration)
                 .setLoopPingPong()
                 .setEaseInOutSine();        
                 LeanTween.rotateAroundLocal(gameObject, Vector3.up, 360f, 60f)
                 .setLoopClamp()
                 .setEaseLinear();

    }

    // Update is called once per frame
    void Update()
    {
        
    }
}
