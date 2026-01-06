using UnityEngine;
using UnityEngine.InputSystem;

public class GrappleState : IPlayerState
{
    private readonly PlayerStateMachine sm;
    private readonly PlayerMovFSM p;

    public GrappleState(PlayerStateMachine sm, PlayerMovFSM p) { this.sm = sm; this.p = p; }

    public void Enter()
    {
        p.ClearFinalWallExitLock();
        if (p.wallRunning != null && p.wallRunning.isWallRunning)
            p.wallRunning.EndWallRun();

        p.animator.SetFloat("Speed", 0f);
        p.animator.SetBool("IsWalking", false);
        AudioMNG.instance.Walking(0);
        AudioMNG.instance.WallRun(0);
    }

    public void Exit() { }

    public void Tick()
    {
        if (p.GrappleActive) return;

        if (p.isGrounded) sm.ChangeState(sm.Walking);
        else sm.ChangeState(sm.Jumping);
    }

    public void FixedTick() { } // grappling system drives motion

    public void OnMove(Vector2 input, InputAction.CallbackContext ctx) { }
    public void OnJumpPressed() { }
    public void OnWallJumpPressed() { }
}
