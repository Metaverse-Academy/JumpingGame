using TMPro;
using UnityEngine;

public class Win : MonoBehaviour
{
    public TextMeshProUGUI winText;
    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        
    }

    // Update is called once per frame
    void Update()
    {

    }
     void OnCollisionEnter(Collision collision)
    {
        if (collision.gameObject.CompareTag("Player"))
        {
            winText.gameObject.SetActive(true);
        }
    }
}
