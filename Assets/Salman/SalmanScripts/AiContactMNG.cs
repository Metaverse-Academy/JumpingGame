using UnityEngine;

public class AiContactMNG : MonoBehaviour
{

    [SerializeField] public  bool[] HiddenPosIsPlayerIn = new bool[6];

    public static AiContactMNG Instance;

    void Awake()
    {
        Instance = this;
    }
    void Start()
    {
        
    }

    void Update()
    {

    }

   public int GetTheLengthOfTheHoddenArrayLength()
    {

      int x =   HiddenPosIsPlayerIn.Length;

        return x;


    }
}
