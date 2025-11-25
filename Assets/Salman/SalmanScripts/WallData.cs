using UnityEngine;

public class WallData : MonoBehaviour
{


    [SerializeField] public bool IsFinalWall;
     [SerializeField] float amplitude = 0.6f, duration = 2f;
    void Start()
    {
        LeanTween.moveY(gameObject, transform.position.y + amplitude, duration)
                 .setLoopPingPong()
                 .setEaseInOutSine();
              
}
}
