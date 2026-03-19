extends CharacterBody3D


const SPEED = 5.0
const JUMP_VELOCITY = 4.5

@onready var ragdoll: PhysicalBoneSimulator3D = $"X Bot/Skeleton3D/PhysicalBoneSimulator3D"
@onready var col: CollisionShape3D = $CollisionShape3D
@onready var anim: AnimationPlayer = $"X Bot/AnimationPlayer"
@onready var skeleton_3d: Skeleton3D = $"X Bot/Skeleton3D"
@onready var hips: PhysicalBone3D = $"X Bot/Skeleton3D/PhysicalBoneSimulator3D/Physical Bone mixamorig_Hips"


func _ready() -> void:
	pass

func _unhandled_input(_event: InputEvent) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		set_ragdoll(not ragdoll.active, Vector3.LEFT * 50)

func set_ragdoll(enabled : bool, impulse : Vector3 = Vector3.ZERO):
	if enabled == ragdoll.active:
		return
	global_position = skeleton_3d.global_position
	skeleton_3d.top_level = enabled
	skeleton_3d.position = Vector3.ZERO
	ragdoll.active = enabled
	col.disabled = enabled
	anim.active = not enabled
	if enabled:
		ragdoll.physical_bones_start_simulation()
		hips.apply_central_impulse(impulse)
	else:
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
