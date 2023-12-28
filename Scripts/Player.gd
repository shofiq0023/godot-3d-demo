extends CharacterBody3D


const WALK_SPEED = 5.0;
const SPRINT_SPEED = 8.0;
const JUMP_VELOCITY = 5.5;
const SENSITIVITY = 0.003;
const BASE_FOV = 75.0;
const FOV_INCR = 1.5

# Head bob
const BOB_FREQ = 2.0;
const BOB_AMP = 0.09;
var t_bob = 0.0;

var speed;
var gravity = 9.8;
@onready var head = $Head;
@onready var camera = $Head/Camera3D;

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _process(delta):
	if Input.is_action_just_pressed("escape"):
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE);
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED);

func _unhandled_input(event):
	if event is InputEventMouse:
		head.rotate_y((event.relative.x * SENSITIVITY) * -1);
		camera.rotate_x((event.relative.y * SENSITIVITY) * -1);
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-40), deg_to_rad(60));

func _physics_process(delta):
	var target_fov = BASE_FOV;
	
	# Handle gravity
	if not is_on_floor():
		velocity.y -= gravity * delta;
	
	# Handle Jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY;
	
	# Handle Sprint
	if Input.is_action_pressed("sprint"):
		speed = SPRINT_SPEED;
		
		# Increase and clamp FOV
		var velocity_clamped = clamp(velocity.length(), 0.5, SPRINT_SPEED * 2);
		target_fov = BASE_FOV + FOV_INCR * velocity_clamped;
	else:
		speed = WALK_SPEED;
	
	var input_dir = Input.get_vector("left", "right", "up", "down");
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized();
	
	# Handle Movement
	if is_on_floor():
		if direction:
			velocity.x = direction.x * speed;
			velocity.z = direction.z * speed;
		else:
			velocity.x = lerp(velocity.x, direction.x * speed, delta * 5.0);
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 5.0);
	else:
		velocity.x = lerp(velocity.x, direction.x * speed, delta * 3.0);
		velocity.z = lerp(velocity.z, direction.z * speed, delta * 3.0);
	
	# Handle headbob
	t_bob += delta * velocity.length() * float(is_on_floor());
	camera.transform.origin = _headbob(t_bob);
	
	# Handle FOV
	camera.fov = lerp(camera.fov, target_fov, delta * 8.0);
	move_and_slide()

func _headbob(time) -> Vector3:
	var pos = Vector3.ZERO;
	pos.y = sin(time * BOB_FREQ) * BOB_AMP;
	pos.x = cos(time * BOB_FREQ / 2) * BOB_AMP;
	
	return pos;






