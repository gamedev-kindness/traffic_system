extends VehicleBody

signal destroyed
var width = 1.4
var length = 3.5
var height = 0.9

var pathpos = 0
var lane = 0
var road = null
var increment = 1
var velocity
var desired_velocity = Vector3()
var steering_data = Vector3()
var MAX_SPEED = 16.8
var MIN_SPEED = 0.7
const MIN_SPEED_VEHICLE = 0.7
const MAX_SPEED_VEHICLE = 16.8
const MAX_ACCEL = 0.1
var THRESH = sqrt((width / 2.0) * (width / 2.0) + (length / 2.0) * (length / 2.0)) * 0.5
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	#MAX_SPEED = 16 * randf() + MIN_SPEED
	velocity = get_linear_velocity()
	brake = 20.0
	sleeping = true
#	$current_mark.set_as_toplevel(true)
#	$target_mark.set_as_toplevel(true)
	$current_mark.queue_free()
	$target_mark.queue_free()
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var current_pos = global_transform.origin
	velocity = get_linear_velocity()
	var next_path_pos = road.get_next_pos(lane, pathpos)
	if next_path_pos == null:
		emit_signal("destroyed")
		queue_free()
		return
#	if !ooo:
#		$target_mark.global_transform.origin = road.get_next_pos(lane, pathpos)
#		$current_mark.global_transform.origin = road.get_road_pos(lane, pathpos)
#		ooo = true
#	if current_pos.distance_to(path[0]) < 1.0 || current_pos.distance_to(path[path.size() - 3]) < 1.0:
#		emit_signal("destroyed")
#		queue_free()
#		return
	if current_pos.distance_to(next_path_pos) < 5.5:
		pathpos += road.get_lane_dir(lane)
		next_path_pos = road.get_next_pos(lane, pathpos)
		if next_path_pos == null:
			emit_signal("destroyed")
			queue_free()
			return
#	$target_mark.global_transform.origin = next_path_pos
	var next_dist = global_transform.xform_inv(next_path_pos)
	var desired_velocity_dir = next_dist.normalized()
#	var steering_dir = velocity.normalized() - desired_velocity_dir
#	var angle = atan2(steering_dir.y, steering_dir.x)
#	var speed = (MAX_SPEED - MIN_SPEED) / (1.0 + angle) + MIN_SPEED
#	if next_dist.length() < sqrt(THRESH) * 2.5:
#		speed = MIN_SPEED
#	desired_velocity = desired_velocity_dir * speed
	desired_velocity = Vector3(next_dist.x, global_transform.origin.y, next_dist.z)
	print(name, "current:", current_pos, " next: ", next_path_pos, "desired_velocity: ", desired_velocity, "length: ", desired_velocity.length(), " ", lane, " ", pathpos)
#	steering_data = velocity - desired_velocity
#	var accel = steering_data * delta
#	if accel.length() > MAX_ACCEL:
#		accel = accel.normalized() * MAX_ACCEL
#	velocity = velocity + accel
#	look_at(current_pos + velocity, transform.basis[1])
#	translation = current_pos + velocity * delta
#	print("steering = ", steering)
#	print("desired_velocity = ", desired_velocity)
#	print("velocity = ", velocity)
#	print("speed=", velocity.length())
#	print(THRESH)
var eforce = 0.0
var dbrake = 0.0
func _physics_process(delta):
	var xvel = get_linear_velocity()
	var chvel = desired_velocity
	if road != null:
		MAX_SPEED = min(MAX_SPEED_VEHICLE, road.max_speed * 1000/ 3600)
		MIN_SPEED = max(MIN_SPEED_VEHICLE, road.min_speed * 1000 / 3600)

	xvel.y = 0
	chvel.y = 0
	if xvel.length() < MIN_SPEED:
		eforce = eforce * 0.9 + mass * 2 * 0.1
		dbrake = dbrake * 0.9
	elif xvel.length() - 0.5 > MAX_SPEED * 0.4 / (1.0 + steering * steering):
		eforce = eforce * 0.9
		dbrake = dbrake * 0.9 + (1.5 + steering * steering * 0.9) * 0.1
	elif xvel.length() - 0.5 > MAX_SPEED:
		eforce = eforce * 0.9
		dbrake = dbrake * 0.9 + 2.0 * 0.1
#	elif steering_data.z > 0:
#		engine_force = -velocity.length() * mass * 0.1
#	if steering_data.x > 1.0:
#		steering = 0.5
#	elif steering_data.x < -1.0:
#		steering = -0.5
#	else:
#		steering = 0.0
	if dbrake < 0.1:
		dbrake = 0.0
	if eforce < 0.1:
		eforce = 0.0
	engine_force = eforce
	brake = dbrake
#	var steerf = xvel - chvel
#	var lsteerf = chvel
#	print("local velocity: ", lsteerf)
#	if abs(lsteerf.x * 0.01) > 0.1 && xvel.length() > 0:
	if chvel.length() > 0:
		steering = -chvel.x / chvel.length() * deg2rad(30)
	else:
		steering = 0.0
#	else:
#		steering = 0.0
#	print("1 ",xvel)
#	print("2 ", chvel)
#	look_at(translation + velocity, transform.basis[1])
#	var stdir = steering_data.normalized()
#	apply_torque_impulse(Vector3(0, -stdir.x * 100.0 * delta, 0))
#	if get_linear_velocity().distance_to(velocity) > 0.0005:
#		set_linear_velocity(velocity)
#	print(velocity)
#	move_and_slide(velocity * delta, Vector3(0, 1, 0), false, 1.0, false)
#	translation = translation + velocity * delta
#	move_and_collide(velocity * delta * 0.01)
