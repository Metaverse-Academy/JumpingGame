using UnityEngine;

public class JumpGround : MonoBehaviour
{
    [SerializeField] private Rigidbody rb;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void FixedUpdate()
    {
        
    }
    void OnCollisionEnter(Collision other)
    {
        if (other.gameObject.CompareTag("Player"))
        {
           rb.AddForce(Vector3.up * 16f , ForceMode.Impulse);

        }
    }
}
