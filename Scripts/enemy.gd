class_name Enemy;

extends Node2D

var rng = RandomNumberGenerator.new();
const spawn_region = Vector2(20, 100);

func _ready() -> void:
	reassign_positions();

func reassign_positions() -> void :
	global_position = Vector2(rng.randf_range(spawn_region.x, spawn_region.y), rng.randf_range(spawn_region.x, spawn_region.y))
	$Puppet.global_position = Vector2(rng.randf_range(spawn_region.x, spawn_region.y), rng.randf_range(spawn_region.x, spawn_region.y));


func _physics_process(delta: float) -> void:
	if Input.is_action_just_pressed("Secondary Action"):
		#reassign_positions();
		pass;
