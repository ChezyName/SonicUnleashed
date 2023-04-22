@tool
extends Node3D

@export var Angle:float = 0
@export var Distance:float = 0
@export var StillTime:float = 5

@onready var MovingPlatform = $MovingPlatform

var startingPos:Vector3 = Vector3()
var endingPos:Vector3 = Vector3()

func updatePosition():
	endingPos = startingPos + Vector3(0, Distance * sin(deg_to_rad(Angle)), Distance * cos(deg_to_rad(Angle)))

@onready var mesh := MeshInstance3D.new()
@onready var imesh := ImmediateMesh.new()
@onready var mat := ORMMaterial3D.new()

var lastAngle = 0
var lastDist = 0

var going = true
var delay = 0

func createMesh():
	mesh = MeshInstance3D.new()
	imesh = ImmediateMesh.new()
	mat = ORMMaterial3D.new()
	mesh.mesh = imesh
	mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	
	imesh.surface_begin(Mesh.PRIMITIVE_LINES,mat)
	imesh.surface_add_vertex(startingPos)
	imesh.surface_add_vertex(endingPos)
	imesh.surface_end()
	
	mat.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	mat.albedo_color = Color.RED
	
	mesh.name = "LINE_MESH"
	add_child(mesh)

func updateMesh():
	var meshNode = get_node_or_null("LINE_MESH")
	if(meshNode != null):
		remove_child(meshNode)
		#print(meshNode.name)
	createMesh()

# Called when the node enters the scene tree for the first time.
func _ready():
	startingPos = self.position
	delay = StillTime
	updatePosition()
	if(Engine.is_editor_hint()): createMesh()
	pass # Replace with function body.

func lerpVector3(BaseVector:Vector3, EndVector:Vector3,time:float):
	var x = lerpf(BaseVector.x,EndVector.x,time)
	var y = lerpf(BaseVector.y,EndVector.y,time)
	var z = lerpf(BaseVector.z,EndVector.z,time)
	return Vector3(x,y,z)
	

func _process(delta):
	if(Engine.is_editor_hint() and (lastAngle != Angle or lastDist != Distance)):
		#print("UPDATING!")
		updatePosition()
		updateMesh()
		lastAngle = Angle
		lastDist = Distance
	elif(!Engine.is_editor_hint()):
		if(going):
			if(!MoveTo(endingPos,delta)):
				if(delay < 0):
					print("COUNTDOWN ENDED!")
					going = false
				else:
					delay -= delta
					print("COUNTDOWN: " + str(delay))
		else:
			if(!MoveTo(startingPos,delta)):
				if(delay < 0):
					print("F COUNTDOWN ENDED!")
					going = true
				else:
					delay -= delta
					print("F COUNTDOWN: " + str(delay))
	pass

func MoveTo(moveToPos:Vector3,delta:float) -> bool:
	var maxDist = moveToPos.distance_to(startingPos)
	if(abs(MovingPlatform.position.distance_to(moveToPos)) > abs(maxDist * 0.15)):
		MovingPlatform.position = lerpVector3(MovingPlatform.position,moveToPos,0.75 * delta)
		print(str(MovingPlatform.position) + " / " + str(moveToPos))
		delay = StillTime
		return true
	else: return false
