extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var ragdoll: PhysicalBoneSimulator3D = $"X Bot/Skeleton3D/PhysicalBoneSimulator3D"
@onready var col: CollisionShape3D = $CollisionShape3D
@onready var anim: AnimationPlayer = $"X Bot/AnimationPlayer"
@onready var skeleton_3d: Skeleton3D = $"X Bot/Skeleton3D"


func _ready() -> void:
	pass

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if not ragdoll.active:
			ragdoll.active = true
			col.disabled = true
			anim.active = false
			skeleton_3d.top_level = true
			ragdoll.physical_bones_start_simulation()
		else:
			global_position = skeleton_3d.global_position
			skeleton_3d.top_level = false
			skeleton_3d.position = Vector3.ZERO
			ragdoll.active = false
			col.disabled = false
			anim.active = true
			ragdoll.physical_bones_stop_simulation()

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	move_and_slide()
