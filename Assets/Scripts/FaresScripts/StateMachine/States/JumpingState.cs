using UnityEngine;
using UnityEngine.InputSystem;

public class JumpingState : IPlayerState
{
    private readonly PlayerStateMachine sm;
    private readonly PlayerMovFSM p;

    public JumpingState(PlayerStateMachine sm, PlayerMovFSM p) { this.sm = sm; this.p = p; }

    public void Enter()
    {
        p.animator.SetBool("IsWalking", false);
        AudioMNG.instance.Walking(0);
    }

    public void Exit() { }

    public void Tick()
    {
        if (p.GrappleActive) { sm.ChangeState(sm.Grapple); return; }
        if (p.isGrounded) { sm.ChangeState(sm.Walking); return; }

        // Try wallrun enter (blocked if final wall lock is active)
        if (!p.FinalWallExitLocked &&
    p.wallRunning != null &&
    p.wallRunning.CanStartWallRun())
{
    sm.ChangeState(sm.WallRunning);
    return;
}

    }

    public void FixedTick()
    {
        if (p.GrappleActive) return;

        p.ApplySoftFall();
        p.ApplyCameraRelativeMove();
    }

    public void OnMove(Vector2 input, InputAction.CallbackContext ctx) { }
    public void OnJumpPressed() { } // no double jump
   public void OnWallJumpPressed()
{
    if (p.wallRunning == null) return;

    if (p.wallRunning.TryWallJump(out bool jumpedFromFinalWall))
    {
        p.LockWallJumpControl(jumpedFromFinalWall ? 0.30f : 0.15f);

        if (jumpedFromFinalWall)
            p.SetFinalWallExitLock();

        // stay in Jumping state (already airborne)
    }
}
}
