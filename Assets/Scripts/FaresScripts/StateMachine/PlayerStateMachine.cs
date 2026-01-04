using UnityEngine;
using UnityEngine.InputSystem;

public class PlayerStateMachine : MonoBehaviour
{
    [field: SerializeField] public PlayerMovFSM Motor { get; private set; }

    public IPlayerState Current { get; private set; }

    // Concrete states
    public WalkingState Walking { get; private set; }
    public JumpingState Jumping { get; private set; }
    public WallRunState WallRunning { get; private set; }
    public GrappleState Grapple { get; private set; }

    private void Awake()
    {
        if (Motor == null) Motor = GetComponent<PlayerMovFSM>();

        Walking     = new WalkingState(this, Motor);
        Jumping     = new JumpingState(this, Motor);
        WallRunning = new WallRunState(this, Motor);
        Grapple     = new GrappleState(this, Motor);
    }

    private void Start()
    {
        ChangeState(Walking);
    }

    private void Update()
    {
        Motor.UpdateSensors();
        Current?.Tick();
    }

    private void FixedUpdate()
    {
        Current?.FixedTick();
    }

    public void ChangeState(IPlayerState next)
    {
        if (next == null || Current == next) return;
        Current?.Exit();
        Current = next;
        Current?.Enter();
    }

    // Input forwarding (called from PlayerMovement)
    public void OnMove(Vector2 input, InputAction.CallbackContext ctx) => Current?.OnMove(input, ctx);
    public void OnJumpPressed() => Current?.OnJumpPressed();
    public void OnWallJumpPressed() => Current?.OnWallJumpPressed();
}
