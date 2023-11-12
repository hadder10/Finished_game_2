extends Node3D

@export_enum("STAND", "MOVE", "FIRE") var action: String = "STAND"
@export var next : Node3D
@export var target : Node3D
@export var wait : float = 0.0
