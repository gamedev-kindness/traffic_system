extends KinematicBody

signal destroyed
var width = 1.4
var length = 3.5
var height = 0.9

var path = []
var pathpos = 0
var increment = 1
var velocity
var MAX_SPEED = 16.3
const MIN_SPEED = 3.5
const MAX_ACCEL = 0.01
var THRESH = sqrt((width / 2.0) * (width / 2.0) + (length / 2.0) * (length / 2.0)) * 0.5
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	#MAX_SPEED = 16 * randf() + MIN_SPEED
	velocity = -transform.basis[2] * 0

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var current_pos = translation
	if current_pos.distance_to(path[0]) < 1.0 || current_pos.distance_to(path[path.size() - 3]) < 1.0:
		emit_signal("destroyed")
		queue_free()
		return
	var next_path_pos = path[pathpos + 3 * increment]
	if current_pos.distance_to(next_path_pos) < 1.7:
		pathpos += 3 * increment
		if pathpos == 0 || pathpos == path.size() - 3:
			emit_signal("destroyed")
			queue_free()
			return
		next_path_pos = path[pathpos + 3 * increment]
	
	var next_dist = (next_path_pos - current_pos)
	var desired_velocity_dir = next_dist.normalized()
	var steering_dir = velocity.normalized() - desired_velocity_dir
	var angle = atan2(steering_dir.y, steering_dir.x)
	var speed = (MAX_SPEED - MIN_SPEED) / (1.0 + angle) + MIN_SPEED
	if next_dist.length() < sqrt(THRESH) * 2.5:
		speed = MIN_SPEED
	var desired_velocity = desired_velocity_dir * speed
	var steering = velocity - desired_velocity
	var accel = -steering * delta
	if accel.length() > MAX_ACCEL:
		accel = accel.normalized() * MAX_ACCEL
	velocity = velocity + accel
	look_at(current_pos + velocity, transform.basis[1])
#	translation = current_pos + velocity * delta
#	print("steering = ", steering)
#	print("desired_velocity = ", desired_velocity)
#	print("velocity = ", velocity)
#	print("speed=", velocity.length())
#	print(THRESH)
func _physics_process(delta):	
#	print(velocity)
	move_and_slide(velocity * delta, Vector3(0, 1, 0), false, 1.0, false)
#	translation = translation + velocity * delta
#	move_and_collide(velocity * delta * 0.01)
