extends KinematicBody2D

onready var animator = get_node("AnimationPlayer")
onready var checkpoints = get_node("../Checkpoints")

var MAX_VELOCITY = 15*60
var velocity = Vector2(0, 0)
var on_ground = true
var to_jump = false
var dash_position = false
var to_dash = false
var can_dash = true
var anim_to_play = "normal"

func _ready():
	set_fixed_process(true)
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_select"):
		to_jump = true
	if event.is_action_pressed("dash") and can_dash:
		dash_position = true
	if event.is_action_released("dash") and can_dash:
		to_dash = true

func _fixed_process(delta):
	print(anim_to_play)
	if (Input.is_action_pressed("ui_right")) and velocity.x < MAX_VELOCITY:
		if on_ground:
			velocity.x += 80
		else:
			velocity.x += 50
	if (Input.is_action_pressed("ui_left")) and -velocity.x < MAX_VELOCITY:
		if on_ground:
			velocity.x -= 80
		else:
			velocity.x -= 50
	if (to_jump and on_ground):
		velocity.y -= 33 * 60
	if (abs(velocity.x) < 30):
		velocity.x = 0
	if (abs(velocity.x) > 0):
		if on_ground:
			velocity.x -= sign(velocity.x)*60
		else:
			velocity.x -= sign(velocity.x)*30
	if to_dash:
		dash_position = false
		can_dash = false
		velocity = 2 * MAX_VELOCITY * get_direction()
	to_jump = false
	to_dash = false
	velocity.y += 100
	var motion = velocity * delta
	if (motion.distance_to(Vector2(0,0)) > MAX_VELOCITY):
		motion = motion.normalized() * MAX_VELOCITY
	var motion = velocity * delta * (1-0.8*dash_position)
	move(motion)
	if (velocity.y < 0):
		on_ground = false
	if (is_colliding()):
		var n = get_collision_normal()
		if (n.y < 0):
			on_ground = true
			can_dash = true
		print(get_collider().is_in_group("Killer"))
		if get_collider().is_in_group("Killer"):
			respawn()
		elif get_collider().is_in_group("Bumper"):
			if abs(n.angle_to(Vector2(1,0).rotated(get_collider().get_rot()))) < (PI-0.5):
				motion = Vector2(motion.x, -50*60*delta).rotated(get_collider().get_rot())
				velocity = motion/delta
				on_ground = false
				move(motion)
			else:
				motion = n.slide(motion)
				velocity = n.slide(velocity)
				move(motion)
		else:
			motion = n.slide(motion)
			velocity = n.slide(velocity)
			move(motion)
	if dash_position:
		anim_to_play = "dash_prep"
	if velocity.x > 0:
		anim_to_play = "run"
		get_node("Sprite").set_flip_h(false)
	elif velocity.x < 0:
		anim_to_play = "run"
		get_node("Sprite").set_flip_h(true)
	elif anim_to_play != "black_flash":
		anim_to_play = "normal"
	if not animator.get_current_animation() == anim_to_play:
		animator.play(anim_to_play)

func get_direction():
	var result = Vector2(0, 0)
	if Input.is_action_pressed("ui_left"):
		result.x -= 1
		result.y -= 1
	if Input.is_action_pressed("ui_right"):
		result.x += 1
		result.y -= 1
	if Input.is_action_pressed("ui_up"):
		result.y -= 1
	if Input.is_action_pressed("ui_down"):
		result.y += 1
	return result.normalized()

func respawn():
	var min_dist = 9999999999
	var closer = 0
	var count = 0
	for cp in checkpoints.get_children():
		var current_dist = cp.get_global_pos().distance_to(get_global_pos())
		if current_dist < min_dist:
			closer = count
			min_dist = current_dist
		count += 1
	set_global_pos(checkpoints.get_child(closer).get_global_pos())
	velocity = Vector2(0, 0)
	on_ground = true
	to_jump = false
	dash_position = false
	to_dash = false
	can_dash = true
	anim_to_play = "black_flash"
	animator.play("black_flash")
	yield(animator, "finished")

func _on_AnimationPlayer_finished():
	if animator.get_current_animation() == "black_flash":
		anim_to_play = "normal"
		animator.play("normal")