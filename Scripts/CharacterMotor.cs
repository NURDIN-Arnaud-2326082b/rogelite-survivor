using Godot;
using System;

public partial class CharacterMotor : CharacterBody2D
{
    private Vector2 _movementInput = Vector2.Zero;
    [Export] private float _speed = 600.0f;
    public void MovementPerformed(Vector2 input)
    {
        _movementInput = input.Normalized();
    }
    public override void _PhysicsProcess(double delta)
    {
        // Character motor logic here
        Velocity = _movementInput * _speed;
        MoveAndSlide();
    }
}
