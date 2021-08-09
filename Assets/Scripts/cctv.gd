extends KinematicBody

#shader
onready var TravelShader = $Control/TravelShader
onready var CameraShader = $Control/CameraShader

#node
onready var head = $Cam
onready var camera = $Cam/Camera
onready var rayCast = $Cam/Camera/RayCast
onready var Casthide = $Cam/Casthide
onready var Labelcctv = $Control/Label
onready var cctv_container = $"../Container/"
onready var Player = $"../Player/"
onready var castedNode
onready var savedNode

#audio node
onready var ZoomSound = $AudioZoom
onready var RotateSound = $AudioRotate

var direction
var travel = false
var destination = Vector3()
var mouse_sens = 0.02
var zoom = 70
var speed = 25


func _ready():
	CameraShader.visible = false
	TravelShader.visible = false
	Labelcctv.visible = false
	destination = self.translation
	self.rotation_degrees.y = 0


func _input(event):
	
	#if 'ESC' pressed
	if event.is_action_pressed("ui_cancel"):
		destination = Player.translation
		
	
	#if 'Q' pressed 
	if event.is_action_pressed("set_cam"):
		#check if castedNode have a translation value
		if castedNode:
			destination = castedNode.translation
			self.rotation_degrees = castedNode.rotation_degrees
			
	
	#zoom
	if event is InputEventMouseButton:
		if event.button_index == BUTTON_WHEEL_UP:
			#max Zoom in Fov = 30
			ZoomSound.play()
			if camera.fov >= 30:
				camera.fov -= 1
		elif event.button_index == BUTTON_WHEEL_DOWN:
			#max zoom out Fov = 70
			ZoomSound.play()
			if camera.fov <= 70:
				camera.fov += 1
	
	#camera rotation
	#when travel = true cam rotate blocked
	if event is InputEventMouseMotion and !travel:
		head.rotate_y(deg2rad(-event.relative.x * mouse_sens))
		#max view angle up and down cctv camera
		camera.rotate_x(deg2rad(event.relative.y * mouse_sens))
		camera.rotation.x = clamp(camera.rotation.x, deg2rad(-50), deg2rad(50))
		
		#max view angle left and right cctv camera
		var head_rotation = head.rotation_degrees
		head_rotation.y = clamp(head_rotation.y, -70, 70)
		head.rotation_degrees = head_rotation
		RotateSound.play(0.50)


func _process(_delta):
	if travel:
		TravelShader.visible = true
		CameraShader.visible = false
	else:
		TravelShader.visible = false
		CameraShader.visible = true
	
	#back to player position (player mode)
	if destination == Player.translation and !travel:
		Player.currentCam = true
		self.queue_free()
	
	#when in cctv mode set camera cctv to current
	if !Player.currentCam :
		camera.current = true
	else:
		camera.current = false
	
	if Casthide.is_colliding():
		#set camera rotation when colliding
		if castedNode:
			self.rotation_degrees = castedNode.rotation_degrees
	
	if rayCast.is_colliding():
		#get staticBody name
		castedNode = cctv_container.get_node(rayCast.get_collider().get_name())
		#staticBody from Container node?? yes? = this is a cctv node , no? = not cctv
		if castedNode.get_parent().get_name() == "Container":
			Labelcctv.visible = true
			castedNode.translation
	else:
		Labelcctv.visible = false

func _physics_process(_delta):
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
	savedNode = body
	savedNode.visible = false

#show cctv when exit area
func _on_HideRange_body_exited(_body):
	savedNode.visible = true
