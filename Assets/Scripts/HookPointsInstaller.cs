using UnityEngine;

public class HookPointsInstaller : MonoBehaviour
{
    [Tooltip("Assign the hook points for THIS level in order.")]
    public Transform[] levelHookPoints;

    private void Start()
    {
        if (HookingMechanic.instance != null)
        {
            HookingMechanic.instance.SetHookPoints(levelHookPoints);
        }
        else
        {
            Debug.LogWarning("HookPointsInstaller: No HookingMechanic.instance found in scene.");
        }
    }
}
