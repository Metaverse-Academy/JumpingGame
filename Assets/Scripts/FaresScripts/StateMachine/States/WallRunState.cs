using UnityEngine;
using UnityEngine.InputSystem;

public class WallRunState : IPlayerState
{
    private readonly PlayerStateMachine sm;
    private readonly PlayerMovFSM p;

    public WallRunState(PlayerStateMachine sm, PlayerMovFSM p) { this.sm = sm; this.p = p; }

    public void Enter()
    {
        if (p.wallRunning == null || !p.wallRunning.HasRunnableWall())
        {
            sm.ChangeState(sm.Jumping);
            return;
        }

        p.wallRunning.BeginWallRun();
    }

    public void Exit()
    {
        if (p.wallRunning != null && p.wallRunning.isWallRunning)
            p.wallRunning.EndWallRun();
    }

    public void Tick()
    {
        if (p.GrappleActive) { sm.ChangeState(sm.Grapple); return; }
        if (p.isGrounded) { sm.ChangeState(sm.Walking); return; }

        if (p.wallRunning == null || !p.wallRunning.HasRunnableWall())
        {
            sm.ChangeState(sm.Jumping);
            return;
        }
    }

    public void FixedTick()
    {
        if (p.GrappleActive) return;
        p.wallRunning.TickWallRunMovement();
    }

    public void OnMove(Vector2 input, InputAction.CallbackContext ctx) { }

    public void OnJumpPressed() => DoWallJump();
    public void OnWallJumpPressed() => DoWallJump();

    private void DoWallJump()
    {
        if (p.wallRunning == null) return;

        if (p.wallRunning.TryWallJump(out bool jumpedFromFinalWall))
        {
            p.LockWallJumpControl(jumpedFromFinalWall ? 0.30f : 0.15f);

            // Requirement: after final wall jump, don't re-enter wallrun until grounded
            if (jumpedFromFinalWall)
                p.SetFinalWallExitLock();

            sm.ChangeState(sm.Jumping);
        }
    }
}
