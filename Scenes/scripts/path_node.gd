extends Node3D

@export_enum("MOVE", "FIRE") var action: String = "MOVE"
@export var next : Node3D
@export var target : Node3D
