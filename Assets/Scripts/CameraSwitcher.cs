// 11/8/2025 AI-Tag
// This was created with the help of Assistant, a Unity Artificial Intelligence product.

using System;
using UnityEditor;
using UnityEngine;
using Unity.Cinemachine;
using UnityEngine.InputSystem;
using NUnit.Framework;
// This script switches between a default Cinemachine Virtual Camera and a Cinemachine FreeLook Camera using the new Input System.


public  class CameraSwitcher : MonoBehaviour
{
    // References to the two cameras.
    public CinemachineCamera defaultCamera;
    public static CameraSwitcher instance;
    public CinemachineCamera freeLookCamera;
    public CinemachineCamera wallRunCamera;
    public WallRunning wallRunning;
    private String Blabla = "blabla";

    // Variable to store the input action for toggling the camera.
    private bool isFreeLookActive = false;
    private bool isWallRunActive = false;

    // This method is called by the Input System when the "ToggleCamera" action is triggered.
    public void OnToggleCamera(InputAction.CallbackContext context)
    {
        // Check if the input action was performed (button pressed).
        if (context.performed)
        {
            // Toggle between the default camera and the FreeLook camera.

            IsFreeLookActiveMethod();
        }

    }
    private void Start()
    {
        instance = this;
    }


    public void ActiveWallRun()
    {

        wallRunCamera.enabled = true;
        defaultCamera.enabled = false;


    }
    public void DeactiveWallRun()
    {

        wallRunCamera.enabled = false;
        defaultCamera.enabled = true;
    }
    public void IsFreeLookActiveMethod()
    {
        isFreeLookActive = !isFreeLookActive;
        freeLookCamera.enabled=isFreeLookActive;
        defaultCamera.enabled=!isFreeLookActive;
    }
}
