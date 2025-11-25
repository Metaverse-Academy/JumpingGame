using UnityEngine;

public abstract class State 
{

    //all states will take from this class 
   //protected Player player;
    protected StateMachine stateMachine;


    // protected State(Player player, StateMachine stateMachine)
    // {
    //     this.player = player;
    //     this.stateMachine = stateMachine;
    // }
    public abstract void Enter() ;
    public abstract void Exit() ;
    public abstract void tick(float deltaTime);

}
