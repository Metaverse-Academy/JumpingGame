using UnityEngine;
using UnityEngine.InputSystem;

public class WalkingState : IPlayerState
{
    private readonly PlayerStateMachine sm;
    private readonly PlayerMovFSM p;

    public WalkingState(PlayerStateMachine sm, PlayerMovFSM p) { this.sm = sm; this.p = p; }

    public void Enter()
    {
        if (p.wallRunning != null && p.wallRunning.isWallRunning)
            p.wallRunning.EndWallRun();
    }

    public void Exit() { }

    public void Tick()
    {
        if (p.GrappleActive) { sm.ChangeState(sm.Grapple); return; }
        if (!p.isGrounded) { sm.ChangeState(sm.Jumping); return; }

        // walking audio (only here)
        if (p.IsWalkingInput) AudioMNG.instance.Walking(1);
        else AudioMNG.instance.Walking(0);
    }

    public void FixedTick()
    {
        if (p.GrappleActive) return;
        p.ApplyCameraRelativeMove();
    }

    public void OnMove(Vector2 input, InputAction.CallbackContext ctx) { }

    public void OnJumpPressed()
    {
        if (p.GrappleActive) return;

        if (p.CanJumpNow())
        {
            p.ConsumeCoyote();
            p.DoNormalJump();
            sm.ChangeState(sm.Jumping);
        }
    }

    public void OnWallJumpPressed() { }
}
