using UnityEngine;

public class PlayerLookAt : MonoBehaviour
{
    [SerializeField] private Camera MainCamera;
    [SerializeField] private GameObject Target;
     private GameObject Player;

    [SerializeField] private Canvas Canvas;
    private float PlayerDis=100; 
    public bool IsTargetvisible;
    void Awake()
    {
        Player = GameObject.FindGameObjectWithTag("Player");
    }
    void Update()
    {
        PlayerDis = Vector3.Distance(Player.transform.position,Target.transform.position);
if(PlayerDis < 15){

        Vector3 cameraRange = MainCamera.WorldToViewportPoint(Target.transform.position);
        bool IsTargetFrontOfCamera = cameraRange.z > 0;
        bool IsTargetInsideRange = cameraRange.x > 0 && cameraRange.x < 1 && cameraRange.y > 0 && cameraRange.y < 1;

        IsTargetvisible = IsTargetFrontOfCamera && IsTargetInsideRange &&Target.activeInHierarchy;
        if (IsTargetvisible)
        {
Canvas.enabled =true;


        }
                 else Canvas.enabled = false;

}
else Canvas.enabled = false;

    }
}
