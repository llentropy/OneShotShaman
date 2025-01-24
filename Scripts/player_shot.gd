class_name PlayerShot;

extends AnimatableBody2D;

const SPEED = 30;

signal EnemyHit;

func initialize(given_position: Vector2 = Vector2.ZERO, given_direction: Vector2 = Vector2.RIGHT, given_speed: float = SPEED):
	position = given_position;
	constant_linear_velocity = given_direction * given_speed;
	pass

func _physics_process(delta: float) -> void:
	var collision = move_and_collide(constant_linear_velocity*delta);
	if collision != null:
		if collision.get_collider().to_string().contains("Enemy"):
			EnemyHit.emit();
			queue_free();

func _on_visible_on_screen_notifier_2d_screen_exited() -> void:
	queue_free();
