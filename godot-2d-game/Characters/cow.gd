extends CharacterBody2D

enum COW_STATE { IDLE, WALK }

@export var move_speed : float = 20

@onready var animation_tree = $AnimationTree
@onready var state_machine = animation_tree.get("parameters/playback")
@onready var sprite = $Sprite2D

var move_direction : Vector2 = Vector2.ZERO
var current_state : COW_STATE = COW_STATE.IDLE
var state_timer : float = 0.0

func _ready():
	pick_new_state()

func _physics_process(delta):
	# Handle state duration timer
	state_timer -= delta
	if state_timer <= 0.0:
		pick_new_state()

	# Move the cow if in WALK state
	if current_state == COW_STATE.WALK:
		velocity = move_direction * move_speed
	else:
		velocity = Vector2.ZERO
		
	move_and_slide()

func select_new_direction():
	# Keep picking until we get a non-zero direction so it actually moves
	while move_direction == Vector2.ZERO:
		move_direction = Vector2(
			randi_range(-1, 1),
			randi_range(-1, 1)
		)

	# Face the right direction when they move
	if move_direction.x < 0:
		sprite.flip_h = true
	elif move_direction.x > 0:
		sprite.flip_h = false

func pick_new_state():
	if current_state == COW_STATE.IDLE:
		# Switch to Walk
		current_state = COW_STATE.WALK
		select_new_direction()
		state_machine.travel("Walk") # Or your blend space
		state_timer = randf_range(1.0, 3.0) # Walk for 1-3 seconds
	else:
		# Switch to Idle
		current_state = COW_STATE.IDLE
		move_direction = Vector2.ZERO
		state_machine.travel("Idle") # Or your blend space
		state_timer = randf_range(2.0, 5.0) # Idle for 2-5 seconds
