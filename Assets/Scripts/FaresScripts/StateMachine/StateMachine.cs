using UnityEngine;

public abstract class StateMachine 
{
    // Start is called once before the first execution of Update after the MonoBehaviour is created
   public State currentState{get;private set;}
   public void ChangeState(State newState)
    {
        if (newState ==null) return;
        if(currentState==newState) return;
        newState?.Exit();
        currentState=newState;
        newState?.Enter();
    }

    private void Update()
    {
        if(currentState==null) return;
        currentState.tick(Time.deltaTime);
    }


}
