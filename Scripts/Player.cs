using Godot;
using System;

public partial class Player : Node
{
    [Export] private PlayerInputs _playerInputs = null;
    [Export] private CharacterMotor _characterMotor = null;


    public override void _Process(double delta)
    {
        _characterMotor.MovementPerformed(_playerInputs.MovementInput);
    }
}
