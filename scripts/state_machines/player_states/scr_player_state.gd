class_name PlayerState extends State

@export var player:Player
var state_forced:bool = false

func GroundMove(delta:float):
	Move.ground_move(player, player.direction, delta)

func ApplyGravity(mult:float, delta:float):
	Move.apply_gravity(player, mult, delta)
