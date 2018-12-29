extends Spatial

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
enum {
	CAMERA_FREE
}
const SPEED = 10.0
const XSPEED = 2.0
const YSPEED = 2.0
var camera_mode = CAMERA_FREE
var roty = 0.0
var rotx = 0.0
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
var vel = Vector3()
var xvel = Vector3()
var mlook = false
var rot_y = 0.0
var rot_x = 0.0
var smoothness = 0.1
func _process(delta):
	rot_y = rot_y * smoothness + roty * (1.0 - smoothness)
	rot_x = rot_x * smoothness + rotx * (1.0 - smoothness)
	xvel = xvel * smoothness + vel * (1.0 - smoothness)
	
	rotate_y(rot_y * YSPEED * delta)
	$Camera.rotate_x(rotx * XSPEED * delta)
	global_translate(xvel * delta)
	roty = 0.0
	rotx = 0.0
func _input(event):
	if camera_mode == CAMERA_FREE:
		vel = Vector3()
		if Input.is_action_pressed("move_forward"):
			vel = -$Camera.global_transform.basis[2] * SPEED
			print("pressed")
		elif Input.is_action_pressed("move_backward"):
			vel = $Camera.global_transform.basis[2] * SPEED
			print("pressed")
		if event is InputEventMouseButton:
			if event.pressed && event.button_index == 2:
				mlook = true
			elif !event.pressed && event.button_index == 2:
				mlook = false
		if event is InputEventMouseMotion && mlook:
			var offt = event.relative
			roty += -offt.x
			rotx += offt.y
#			if offt.y > 0:
#				rotx += 0.1
#			if offt.y < 0:
#				rotx -= 0.1
#			roty = clamp(roty, -0.3, 0.3)
#			rotx = clamp(rotx, -0.3, 0.3)
				
