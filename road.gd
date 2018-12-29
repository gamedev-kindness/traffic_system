extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
var car_positions = []
var car_look_at = []
var lanes = []
var lane_count = 2
var lane_width = 3
var lane_dir = [-1 , 1]
const MAX_CARS = 1
const MIN_CARS = 1
var curve
var max_speed = 80.0
var min_speed = 30
var sidewalk_width = 3.0
var sidewalk_left = true
var sidewalk_right = true

func get_lane_count(lane):
	return lanes[lane].path_pos.size()
func get_road_pos(lane, pos):
	return lanes[lane].path_pos[pos]
func get_next_pos(lane, pos):
	var npos = pos + lane_dir[lane]
	var lcnt = get_lane_count(lane)
	if npos >= lcnt || npos < 0:
		return null
	else:
		return get_road_pos(lane, npos)
func create_sidewalk(path, offset):
	var sidewalk_points = [Vector2(-sidewalk_width / 2.0, 0.0), Vector2(-sidewalk_width / 2.0, 0.7), Vector2(0.0, 0.7), Vector2(sidewalk_width / 2.0, 0.7), Vector2(sidewalk_width/2.0, 0.0)]
	var sidewalk_data = []
	for k in sidewalk_points:
		sidewalk_data.append(k + Vector2(offset, 0.0))
	var swb = StaticBody.new()
	swb.name = "sidewalk_body"
	var swp = CSGPolygon.new()
	swp.polygon = PoolVector2Array(sidewalk_data)
	swp.mode = CSGPolygon.MODE_PATH
	swp.path_node = path.get_path()
	swp.use_collision = true
	swp.invert_faces = true
	swp.path_rotation = CSGPolygon.PATH_ROTATION_PATH_FOLLOW
	swp.add_to_group("navigation")
	swb.add_child(swp)
	add_child(swb)
	
func get_lane_dir(lane):
	return lane_dir[lane]
func create_lanes():
	for h in range(lane_count):
		var lane = {
			"path_pos": [],
			"path_normal": [],
			"path_up": [],
			"dir": lane_dir[h]
			}
		var road_points = curve.get_baked_points()
		var up_vectors = curve.get_baked_up_vectors()
		for k in range(road_points.size()):
			var p = road_points[k]
			var n = Vector3()
			var pos = lane_width * (h - lane_count / 2) + lane_width / 2.0
			if k < road_points.size() - 1:
				var next = road_points[k + 1]
				n = (next - p).cross(up_vectors[k]).normalized()
			elif k > 0:
				var next = road_points[k - 1]
				n = (p - next).cross(up_vectors[k]).normalized()
			p += n * pos + up_vectors[k] * 0.45 + global_transform.origin
			lane.path_pos.append(p)
			lane.path_normal.append(n)
			lane.path_up.append(up_vectors[k])
		lanes.append(lane)
#func car_destroyed(lane):
#	return
#	print("num cars=", num_cars)
#	num_cars -= 1
#	if num_cars > MIN_CARS && randf() > 0.7:
#		return
#	if num_cars > MAX_CARS:
#		return
#	var car_t = randi() % car_types.size()
#	var data = car_types[car_t]
#	var c = data.instance()
#	add_child(c)
#	var lanepos = -1
#	if lane_dir[lane] > 0:
#		lanepos = lanes[lane].size() - 3
#	else:
#		lanepos = 3
#	c.translation = lanes[lane][lanepos] + Vector3(0, 0.2, 0)
#	c.path = lanes[lane]
#	c.pathpos = lanepos
#	c.increment = lane_dir[lane]
#	c.connect("destroyed", self, "car_destroyed", [lane])
#	var pidx = car_positions.find([lane, lanepos])
#	var dir = Vector3()
#	var pidlane = car_positions[pidx][0]
#	var pidpos = car_positions[pidx][1]
#	if pidpos >= 0 && pidpos < lanes[pidlane].size() - 3:
#		dir =  lanes[pidlane][pidpos + 3] - lanes[lane][lanepos]
#		if lane_dir[lane] > 0:
#			c.look_at(lanes[lane][lanepos] - dir, Vector3(0, 1, 0))
#		else:
#			c.look_at(lanes[lane][lanepos] + dir, Vector3(0, 1, 0))
#	elif pidpos > 0 && pidpos == lanes[pidlane].size() - 1:
#		dir = lanes[pidlane][pidpos - 3] - lanes[lane][lanepos]
#		if lane_dir[lane] > 0:
#			c.look_at(lanes[lane][lanepos] - dir, Vector3(0, 1, 0))
#		else:
#			c.look_at(lanes[lane][lanepos] + dir, Vector3(0, 1, 0))
#var count = 0
func spawn():
	var new_positions = []
#	print(curve.get_baked_length())
	for lane in range(lanes.size()):
#		print("spawn lane ", lane)
		var points = lanes[lane].path_pos
		for k in range(points.size()):
			if true:
				var ok = true
				for l in car_positions:
					if points[k].distance_to(get_road_pos(l[0], l[1])) < 10 && lane == l[0]:
						ok = false
						break
				if ok:
					car_positions.append([lane, k])
					new_positions.append([lane, k])
	if car_positions.size() > 2:
		for k in new_positions:
			var c = preload("res://vehicle_spwaner.tscn").instance()
			c.translation = get_road_pos(k[0], k[1]) + Vector3(0, 0.5, 0)
			c.path = lanes[k[0]]
			c.pathpos = k[1]
			c.increment = lane_dir[k[0]]
			c.lane = k[0]
#			print("spawner: ", c.global_transform.origin)
			add_child(c)
#			count += 1
#			if count > 20:
#				break
#			c.connect("destroyed", self, "car_destroyed", [k[0]])
#			var pidx = car_positions.find(k)
#			var dir = Vector3()
#			var pidlane = car_positions[pidx][0]
#			var pidpos = car_positions[pidx][1]
#			if pidpos >= 0 && pidpos < lanes[pidlane].size() - 3:
#				dir =  lanes[pidlane][pidpos + 3] - lanes[k[0]][k[1]]
#				if lane_dir[k[0]] > 0:
#					c.look_at(lanes[k[0]][k[1]] - dir, Vector3(0, 1, 0))
#				else:
#					c.look_at(lanes[k[0]][k[1]] + dir, Vector3(0, 1, 0))
#			elif pidpos > 0 && pidpos == lanes[pidlane].size() - 1:
#				dir = lanes[pidlane][pidpos - 3] - lanes[k[0]][k[1]]
#				if lane_dir[k[0]] > 0:
#					c.look_at(lanes[k[0]][k[1]] - dir, Vector3(0, 1, 0))
#				else:
#					c.look_at(lanes[k[0]][k[1]] + dir, Vector3(0, 1, 0))
		
#var delay = 3.0
#var count = 0.0
var spawned = false
func _ready():
	curve = $road_body/Path.curve
	curve.bake_interval = 0.5
	curve.up_vector_enabled = true
	add_to_group("road")
	create_lanes()
	if sidewalk_left:
		create_sidewalk($road_body/Path, -4.5)
	if sidewalk_right:
		create_sidewalk($road_body/Path, 4.5)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if !spawned:
		spawn()
#		print(car_positions)
		spawned = true
