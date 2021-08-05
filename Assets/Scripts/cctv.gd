extends KinematicBody

onready var head = $Cam
onready var camera = $Cam/Camera
onready var rayCast = $Cam/Camera/RayCast
onready var Casthide = $Cam/RayCast
onready var next_cctv = $"../Container/cctv2"
onready var cctv_3 = $"../Container/cctv3"
onready var cctv_view = $"../Container/cctv2/MeshInstance"
onready var cctv_node = $"../Container"

var zoom = 70
var speed = 25
var mouse_sens = 0.02
var direction
var destination = Vector3()
var terbang = false

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	destination = self.translation
	self.rotation_degrees.y = 0

func _input(event):
	if event.is_action_pressed("interact"):
		destination = next_cctv.translation
	#zoom
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			#max Zoom in Fov = 30
			if camera.fov > 30:
				camera.fov -= 1
		elif event.button_index == BUTTON_WHEEL_DOWN:
			#max zoom out Fov = 70
			if camera.fov < 70:
				camera.fov += 1
	
	if event is InputEventMouseMotion and !terbang:
		head.rotate_y(deg2rad(-event.relative.x * mouse_sens))
		#camera.rotate_x(deg2rad(event.relative.y * mouse_sens))
		
		camera.rotate_x(deg2rad(event.relative.y * mouse_sens))
		camera.rotation.x = clamp(camera.rotation.x, deg2rad(-50), deg2rad(50))
		
		var head_rotation = head.rotation_degrees
		head_rotation.y = clamp(head_rotation.y, -70, 70)
		head.rotation_degrees = head_rotation
	
func _process(delta):
	if Casthide.is_colliding():
		#print(Casthide.get_collider().get_name())
		if Casthide.get_collider().get_name() == "cctv2":
			print(next_cctv.rotation_degrees)
			self.rotation_degrees = next_cctv.rotation_degrees
			cctv_node.remove_child(next_cctv)
		if Casthide.get_collider().get_name() == "cctv3":
			self.rotation_degrees = cctv_3.rotation_degrees
			cctv_node.remove_child(next_cctv)
	
	if rayCast.is_colliding():
		if rayCast.get_collider().get_name() == "cctv3":
			next_cctv = cctv_3
			destination = next_cctv.translation

func _physics_process(delta):
	if destination.distance_to(transform.origin) > 0.5:
		terbang = true
		direction = destination - transform.origin
		direction = direction.normalized() * speed
		move_and_slide(direction)
	else:
		terbang = false
