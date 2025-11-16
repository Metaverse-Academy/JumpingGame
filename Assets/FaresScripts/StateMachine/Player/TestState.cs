using UnityEngine;

public class TestState : PlayerBaseState
{
    public TestState(PlayerStateMachine playerStateMachine) : base(playerStateMachine)
    {
    }

    public override void Enter()
    {
        Debug.Log("we are In State BABBYYY");
    }

    public override void Exit()
    {
        Debug.Log("we have exited State");
    }

    public override void tick(float deltaTime)
    {
    }
}
