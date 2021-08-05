extends KinematicBody

onready var head = $Cam
onready var camera = $Cam/Camera
onready var rayCast = $Cam/Camera/RayCast
onready var Casthide = $Cam/Casthide
onready var cctv_container = $"../Container/"
onready var castedNode
onready var savedNode

var direction
var travel = false
var destination = Vector3()
var mouse_sens = 0.02
var zoom = 70
var speed = 25


func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	destination = self.translation
	self.rotation_degrees.y = 0


func _input(event):
	#if 'E' pressed 
	if event.is_action_pressed("interact"):
		#check if castedNode have a translation value
		if castedNode:
			destination = castedNode.translation
	
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
	
	#camera rotation
	if event is InputEventMouseMotion and !travel:
		head.rotate_y(deg2rad(-event.relative.x * mouse_sens))
		#camera.rotate_x(deg2rad(event.relative.y * mouse_sens))
		
		camera.rotate_x(deg2rad(event.relative.y * mouse_sens))
		camera.rotation.x = clamp(camera.rotation.x, deg2rad(-50), deg2rad(50))
		
		var head_rotation = head.rotation_degrees
		head_rotation.y = clamp(head_rotation.y, -70, 70)
		head.rotation_degrees = head_rotation


func _process(delta):
	if Casthide.is_colliding():
		#set camera rotation when colliding
		self.rotation_degrees = castedNode.rotation_degrees
	
	if rayCast.is_colliding():
		#get staticBody name
		castedNode = cctv_container.get_node(rayCast.get_collider().get_name())
		
		#staticBody from Container node?? yes? = this is a cctv node , no? = not cctv
		if castedNode.get_parent().get_name() == "Container":
			castedNode.translation
			#print("this node from Container")

func _physics_process(delta):
	#when the distance > 0.5 the camera is moving
	if destination.distance_to(transform.origin) > 0.5:
		travel = true
		direction = destination - transform.origin
		direction = direction.normalized() * speed
		move_and_slide(direction)
	else:
		travel = false

#hide cctv when entered area
func _on_HideRange_body_entered(body):
	savedNode = castedNode
	savedNode.visible = false

#show cctv when exit area
func _on_HideRange_body_exited(body):
	savedNode.visible = true
