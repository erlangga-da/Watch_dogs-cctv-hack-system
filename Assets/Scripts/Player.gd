extends Spatial

onready var head = $"."
onready var camera = $Camera
onready var raycast = $Camera/RayCast
onready var Labelcctv = $Control/cctvLabel
onready var cctv_container = $"../Container/"
onready var worldNode = $"../"

onready var cctv_cam = preload("res://Assets/Scenes/cctv_camera.tscn")

var castedNode
var currentPos = Vector3()
var currentRot = Vector3()
var spawnPosition = Vector3()
var currentCam = true
var canSpawn = false
var mouse_sens = 0.02

func _ready():
	Labelcctv.visible = false
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _input(event):
	#spawn camera cctv
	if event.is_action_pressed("set_cam") and canSpawn and currentCam:
		var cctv = cctv_cam.instance()
		self.get_parent().add_child(cctv)
		currentCam = false
		var getCctv = $"../KinematicBody"
		getCctv.translation = self.translation
		getCctv.destination = spawnPosition
		getCctv.rotation_degrees = self.rotation_degrees
	#camera rotation
	if event is InputEventMouseMotion and currentCam:
		head.rotate_y(deg2rad(-event.relative.x * mouse_sens))
		#camera.rotate_x(deg2rad(event.relative.y * mouse_sens))
		
		camera.rotate_x(deg2rad(event.relative.y * mouse_sens))
		camera.rotation.x = clamp(camera.rotation.x, deg2rad(-80), deg2rad(80))

func _process(delta):
	currentPos = self.translation
	currentRot = self.rotation_degrees
	if raycast.is_colliding():
		#get staticBody name
		castedNode = cctv_container.get_node(raycast.get_collider().get_name())

		#staticBody from Container node?? yes? = this is a cctv node , no? = not cctv
		if castedNode.get_parent().get_name() == "Container":
			spawnPosition = castedNode.translation
			if currentCam:
				Labelcctv.visible = true
			else:
				Labelcctv.visible = false
			canSpawn = true
		else:
			canSpawn = false
	else:
		Labelcctv.visible = false
