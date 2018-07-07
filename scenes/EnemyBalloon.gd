extends KinematicBody2D

onready var player = get_node("../../Player")
onready var LoS = get_node("../../LoS")
onready var animator = get_node("AnimationPlayer")
onready var sprite = get_node("Sprite")

var velocity = Vector2()
var MAX_VELOCITY = 15*60
var acceleration = 30
var anim_to_play = "normal"

func _ready():
	set_fixed_process(true)

func _fixed_process(delta):
	anim_to_play = "normal"
	var player_pos = player.get_global_pos()
	LoS.set_global_pos(get_global_pos())
	LoS.set_cast_to(2*(player_pos-get_pos()))
	if (LoS.is_colliding() and get_global_pos().distance_to(player_pos) < 800):
		if (LoS.get_collider().is_in_group("Player")):
			anim_to_play = "angry"
			if (abs(get_global_pos().x-player_pos.x) < 1):
				velocity.x = 0
			else:
				if (get_global_pos().x > player_pos.x):
					velocity.x -= acceleration
				else:
					velocity.x += acceleration
			if (abs(get_global_pos().y-player_pos.y) < 1):
				velocity.y = 0
			else:
				if (get_global_pos().y > player_pos.y):
					velocity.y -= acceleration
				else:
					velocity.y += acceleration
	if velocity.x >= 0:
		sprite.set_flip_h(false)
	else:
		sprite.set_flip_h(true)
	if (velocity.distance_to(Vector2()) > MAX_VELOCITY):
		velocity.normalized() * MAX_VELOCITY
	var motion = velocity * delta
	move(motion)
	if (is_colliding()):
		var n = get_collision_normal()
		motion = n.slide(motion)
		velocity = n.slide(velocity)
		move(motion)
	if (not animator.get_current_animation() == anim_to_play):
		animator.play(anim_to_play)

func die():
	queue_free()