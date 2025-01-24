extends CharacterBody2D


const SPEED = 50.0;
var aim_line_direction = Vector2.RIGHT;
var stopped : bool = false;
const shotScene = preload("res://Scenes/PlayerShot.tscn");
@export var aim_speed = 3.0;


func update_aim(direction: float, delta: float):
	$AimLine.clear_points();
	
	aim_line_direction = Vector2.from_angle(aim_line_direction.angle() + direction * delta * aim_speed).normalized();
	
	var firstPoint = aim_line_direction * 10;
	var secondPoint =  aim_line_direction * 18;
		
	$AimLine.add_point(firstPoint);
	$AimLine.add_point(secondPoint);

func clear_aim():
	$AimLine.clear_points();
	
func shoot():
	var shot = shotScene.instantiate();
	get_tree().root.add_child(shot);
	shot.initialize(position + aim_line_direction * 10, aim_line_direction, SPEED + 10);

func _physics_process(delta: float) -> void:
	var horizontal_direction := Input.get_axis("ui_left", "ui_right")
	var vertical_direction := Input.get_axis("ui_up", "ui_down")
	stopped = false;
	
	
	if Input.is_action_pressed("Secondary Action"):
		update_aim(horizontal_direction, delta);
		stopped = true;
	else:
		clear_aim()
		
	if Input.is_action_just_released("Secondary Action"):
		shoot();
	
	if Input.is_action_pressed("Main Action"):
		stopped = true;
			
		
	if horizontal_direction and not stopped:
		velocity.x = horizontal_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if vertical_direction and not stopped:
		velocity.y = vertical_direction * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	move_and_slide()
