using UnityEngine;

public class WallData : MonoBehaviour
{


    [SerializeField] public bool IsFinalWall;
      float amplitude = 0.6f, duration = 2f;
    void Start()
    {
        LeanTween.moveY(gameObject, transform.position.y + amplitude, duration)
                 .setLoopPingPong()
                 .setEaseInOutSine();
       LeanTween.moveX(gameObject, transform.position.x + amplitude, duration)
                 .setLoopPingPong()
                 .setEaseInOutSine();          
}
}
