extends Node2D

@export var FirstTarget : Node2D;
@export var SecondTarget: Node2D;
const pointScene = preload("res://Scenes/TrajectoryPoint.tscn");

@export var initial_scramble_amount: float = 50.0;
@export var align_factor = 0.3;
@export var jumble_factor = 0.1;
@export var blink_threshold = 5.0;

var point_nodes_list : Array[Node] = [];
var points_target_positions_dict = {};
var aligned_points_dict = {};
var rng = RandomNumberGenerator.new();
var initial_color : Color;
var point_to_align_index = 0;

func _ready() -> void:
	position = Vector2.ZERO;
	initial_color = $Line.default_color;
	$Path.curve = Curve2D.new();

func scramble_point_position(target_position: Vector2, factor: float = 0) -> Vector2:
	var scrambled_position = target_position + randomized_vector(20+ factor);
	return scrambled_position;

func randomized_vector(factor = 50.0) -> Vector2:
	return Vector2(randf_range(-factor, factor), randf_range(-factor, factor));

func complicate_curve():
	var lerp_factor = 0.5;
	var increment = 0.3;
	const max_lerp_factor = 0.6;
	while lerp_factor < max_lerp_factor:
		var curve_point = FirstTarget.position.lerp(SecondTarget.position, lerp_factor);
		var max_x = max(FirstTarget.position.x, SecondTarget.position.x);
		var max_y = max(FirstTarget.position.y, SecondTarget.position.y);
		var min_x = min(FirstTarget.position.x, SecondTarget.position.x);
		var min_y = max(FirstTarget.position.y, SecondTarget.position.y);
		
		curve_point += randomized_vector(2.0);
		
		curve_point = curve_point.clamp(Vector2(min_x, min_y), Vector2(max_x, max_y));
		var in_vector = randomized_vector(5.0);
		var out_vector = in_vector.rotated(180);
		
		$Path.curve.add_point(curve_point, in_vector, out_vector);
		lerp_factor += increment;

func generate() -> void:
	vanish();
	points_target_positions_dict.clear();
	$Path.curve.clear_points();
	$Path.curve.add_point(FirstTarget.position, Vector2.ZERO, randomized_vector(50));
	
	
	$Path.curve.add_point(SecondTarget.position,  randomized_vector(50), Vector2.ZERO);

	var target_positions = $Path.curve.tessellate();
	
	var scramble_factor = 0;
	var scramble_increment = 0.2;
	print(target_positions.size())
	for target_position in target_positions:
		var point = Node2D.new();
		point.position = scramble_point_position(target_position, scramble_factor);
		point.position = clamp(point.position, Vector2.ONE*8, Vector2.ONE*120);
		$Line.add_point(point.position);
		add_child(point);
		point_nodes_list.append(point);
		points_target_positions_dict[point] = target_position;
		scramble_factor += scramble_increment;
		


func align_points(delta: float) -> void:
	if point_to_align_index >= point_nodes_list.size():
		return;
	var align_factor = (point_nodes_list.size()) * delta;
	if align_factor > 0.9:
		align_factor = 0.9
	if(point_to_align_index ==0):
		print(align_factor);
	
	var max_distance_from_target : float = 0;
	var point_to_align = point_nodes_list[point_to_align_index];
	point_to_align.position = point_to_align.position.lerp(points_target_positions_dict[point_to_align], align_factor);
	
	$Line.points[point_to_align_index] = point_to_align.position;
	
	if point_to_align.position.distance_to(points_target_positions_dict[point_to_align]) < 0.05:
		point_to_align_index += 1;
		
func vanish():
	point_to_align_index = 0;
	$Line.default_color = initial_color;
	$Line.clear_points();
	$Path.curve.clear_points();
	for point in point_nodes_list:
		point.queue_free();
	point_nodes_list = [];

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("Main Action"):
		generate();
	if Input.is_action_just_released("Main Action"):
		vanish();
	if Input.is_action_pressed("Main Action"):
		align_points(delta);
