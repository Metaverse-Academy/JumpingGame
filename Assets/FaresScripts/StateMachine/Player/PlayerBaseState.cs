using UnityEngine;

public abstract class PlayerBaseState : State
{
    protected PlayerStateMachine playerState;
    public PlayerBaseState(PlayerStateMachine playerStateMachine)
    {
        playerState = playerStateMachine;
    }
}
