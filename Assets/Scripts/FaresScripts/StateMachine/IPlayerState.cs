using UnityEngine;
using UnityEngine.InputSystem;

public interface IPlayerState
{
    void Enter();
    void Exit();
    void Tick();
    void FixedTick();

    void OnMove(Vector2 input, InputAction.CallbackContext ctx);
    void OnJumpPressed();
    void OnWallJumpPressed();
}
