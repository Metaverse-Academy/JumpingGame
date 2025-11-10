using UnityEngine;

public class AudioMNG : MonoBehaviour
{

    public static AudioMNG instance;


    [SerializeField] private AudioSource RopeSwing;
        [SerializeField] private AudioSource walk;

    [SerializeField] private AudioSource ForSounds;
    [SerializeField] private AudioClip ThrowHook;
    [SerializeField] private AudioClip Jump;
    [SerializeField] private AudioClip MonkeyDeath;




    // Start is called once before the first execution of Update after the MonoBehaviour is created
    void Start()
    {
        instance = this;
    }

    // Update is called once per frame
    void Update()
    {

    }
    public void RopeSWing(int x)
    {
        //1 to turn the sound , 0 to trun the sound
        if (x == 1)
        {
            RopeSwing.enabled = true;



        }
        else if (x == 0)
        {
            RopeSwing.enabled = false;



        }

    }


public void Walking(int x)
    {
        //1 to turn the sound , 0 to trun the sound
        if (x == 1)
        {
            walk.enabled = true;



        }
        else if (x == 0)
        {
            walk.enabled = false;



        }

    }

    public void PlaySounds(int x)
    {
        //1 = throwHook 2 - Jump 3 - MonkeyDeath

        if (x == 1)
        {
            ForSounds.PlayOneShot(ThrowHook);


        }
        if (x == 2)
        {
            ForSounds.PlayOneShot(Jump);


        }
 if (x == 3)
        {
            ForSounds.PlayOneShot(MonkeyDeath);


        }


    } 
}
