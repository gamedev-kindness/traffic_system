extends Spatial

var max_vehicles = 5
var vehicle_types = [preload("res://vehicle1-vehicle.tscn")]
var ignore_bodies
var road
var path
var pathpos
var increment
var lane
var spawn = false
# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	ignore_bodies = $area_close.get_overlapping_bodies()
	var timer = Timer.new()
	timer.process_mode = Timer.TIMER_PROCESS_IDLE
	timer.one_shot = false
	timer.wait_time = 1.2
	timer.connect("timeout", self, "timeout")
	add_child(timer)
	road = get_parent()
	spawn_vehicle()

func spawn_random_car():
#	print("spawn ", global_transform.origin)
	var car = vehicle_types[randi() % vehicle_types.size()].instance()
	get_tree().get_root().add_child(car)
#	car.set_as_toplevel(true)
	car.add_to_group("vehicle")
	car.global_transform = global_transform
	car.road = road
	car.lane = lane
	car.pathpos = pathpos
	var npos = road.get_next_pos(lane, pathpos)
	if npos != null:
		car.look_at(npos, Vector3(0, 1, 0))
	
func timeout():
	print("timeout")
	if !$VisibilityNotifier.is_on_screen():
		spawn_vehicle()

func spawn_vehicle():
	var count = 0
	var dcount = 0
	var ovl = $area_close.get_overlapping_bodies()
	var ovl2 = $area_distant.get_overlapping_bodies()
	for h in ovl:
		if h.is_in_group("vehicle"):
			count += 1
	for h in ovl2:
		if h.is_in_group("vehicle"):
			dcount += 1
	if count == 0 && dcount < max_vehicles && randf() < 0.2:
		spawn_random_car()
	