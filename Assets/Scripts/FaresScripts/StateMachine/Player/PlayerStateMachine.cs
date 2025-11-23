using UnityEngine;

public class PlayerStateMachine : StateMachine
{
    private void Start()
    {
        ChangeState(new TestState(this));
    }
}
