using UnityEngine;

public class BulletScripts : MonoBehaviour
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        transform.Translate(Vector3.forward *  19f*Time.deltaTime);
        // transform.forward += 1;
    }
}
