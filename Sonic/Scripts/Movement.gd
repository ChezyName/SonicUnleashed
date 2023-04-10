extends RigidBody3D

const SpinSpeed = 16;
const GroundSpeed = 16;
const AirSpeed = 14;
const SlowDownPercentage = 0.75;
const AirControlPercentage = 0.6;
const SpeedForSuper = 120;

var facingForward = true;
var Rolling = false;
var ForceGravity = 0;

var SonicMesh:Node3D;
var MeshHolder:Node3D;
var GroundCheck:RayCast3D;
var Animator:AnimationPlayer;
var Spedometer:RichTextLabel;
var CollisionBody:CollisionShape3D;
var RingPrefab:Resource;
var TotalRings:int;

var SpinDashing:bool = false
var SpinDashCharge = 0

@export var SpeedMS:int = 0;

func onRing():
	if(abs(self.linear_velocity.z) > 0):
		self.linear_velocity.z += (self.linear_velocity.z * 0.005) + (8 * (self.linear_velocity.z/abs(self.linear_velocity.z)));
	TotalRings += 1

func takeDamage(goThruRoll):
	if(!goThruRoll and Rolling): return
	if(TotalRings <= 0):
		print("DEATH NOISES!")
	else:
		for i in TotalRings:
			var newRing:RigidBody3D = RingPrefab.instantiate()
			newRing.position = self.position
			get_tree().current_scene.add_child(newRing)
			TotalRings -= 1;

func _ready():
	SonicMesh = get_node("MeshHolder/SonicMesh");
	GroundCheck = get_node("GroundCheck")
	Animator = get_node("MeshHolder/SonicMesh/AnimationPlayer")
	Spedometer = get_node("HUD/Speed")
	MeshHolder = get_node("MeshHolder")
	CollisionBody = get_node("Collision")
	RingPrefab = load("res://Prefabs/SonicDroppedRing.tscn")
	pass # Replace with function body.

# process velocity and play animation based on that
func PlayAnimation(velocity,OnGround) -> void:
	if(OnGround and !Rolling and !SpinDashing):
		Animator.speed_scale = clamp(abs(velocity.z) / 10,0,40);
		MeshHolder.rotation_degrees.x = 0
		if(abs(velocity.z) > SpeedForSuper): Animator.play("sc_boost");
		else: Animator.play("sc_run");
	else:
		Animator.speed_scale = 0;
		Animator.play("sc_jump_ball");
		if(SpinDashing):
			if(facingForward): MeshHolder.rotation_degrees.x += 250 * clamp(SpinDashCharge/20,1,20);
			else: MeshHolder.rotation_degrees.x -= 250 * clamp(SpinDashCharge/20,1,20);
		else:
			if(facingForward): MeshHolder.rotation_degrees.x += 250 * clamp(Animator.speed_scale,1,20);
			else: MeshHolder.rotation_degrees.x -= 250 * clamp(Animator.speed_scale,1,20);
	
	#print(velocity)

func CameraZoom(speed):
	$Camera3D.fov = 75 * clamp((speed / 80) + 0.2,0.8,1.6)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	var MoveInput:Vector2 = Input.get_vector("Left","Right","Backward","Forward");
	var isOnGround:bool = GroundCheck.is_colliding() or $GroundCheck2.is_colliding() or $GroundCheck3.is_colliding()
	
	var justSpun = false
	if(SpinDashing and !Input.is_action_pressed("Backward") or !Input.is_action_pressed("Jump")):
		#Was Spindashing
		self.linear_velocity.z += SpinDashCharge
		justSpun = true
	
	SpinDashing = isOnGround and Input.is_action_pressed("Backward") and Input.is_action_pressed("Jump") and abs(self.linear_velocity.z) <= 0.01
	if(SpinDashing): 
		var speedMulti = (1 - clamp(SpinDashCharge/400,0,1))
		SpinDashCharge += (speedMulti*speedMulti) * 25 * delta
		SpinDashCharge = clamp(SpinDashCharge,0,100)
	else: SpinDashCharge = 0
	
	var c_Vel = self.linear_velocity;
	
	Rolling = (isOnGround and Input.is_action_pressed("Backward") and int(abs(c_Vel.z)) > 0) or ($RoofCheck.is_colliding())
	
		#Flip Character Based On facingForward
	if(facingForward): SonicMesh.rotation_degrees.y = 0;
	else: SonicMesh.rotation_degrees.y = 180;
	
	var XInput = MoveInput.x;
	if(abs(MoveInput.x) > 0):
		if(abs(c_Vel.z) > 0.5): XInput = MoveInput.x;
		elif((c_Vel.z > 0.5 and MoveInput.x <= -0.5) or (c_Vel.z < -0.5 and MoveInput.x >= 0.5)):
			XInput = -((c_Vel.z * SlowDownPercentage) * 6);
		elif(c_Vel.z <= 0.5 and MoveInput.x <= -0.5):
			XInput = -1;
			facingForward = false;
		else: facingForward = true;
	elif (MoveInput.x == 0 and abs(c_Vel.z) > 0):
		XInput = -((c_Vel.z * SlowDownPercentage) * 2);
	elif(MoveInput.x == 0 and abs(c_Vel.z) == 0):
		c_Vel.z = 0;
		XInput = 0
	
	if($RoofCheck.is_colliding() and abs(c_Vel.z) <= 15): XInput = MoveInput.x;
	
	c_Vel.z += (XInput * GroundSpeed * delta)
	
	if isOnGround and Input.is_action_just_pressed("Jump"):
		c_Vel.y = 8 * clamp((abs(c_Vel.z) / 100) + 1,1,1.25);
	elif(!isOnGround and Input.is_action_pressed("Jump")):
		c_Vel.y -= 9.8 * delta;
	elif(!isOnGround and Input.is_action_pressed("Backward")):
		c_Vel.y -= 16.8 * delta;
	elif(!isOnGround):
		c_Vel.y -= 12.8 * delta;
	
	c_Vel.z = clamp(c_Vel.z,-400,400)
	if(!SpinDashing and !justSpun):
		if(isOnGround): self.linear_velocity = c_Vel;
		else:
			self.linear_velocity.y = c_Vel.y;
	elif(justSpun):
		self.linear_velocity.z += SpinDashCharge
	
	# Visuals
	if(SpinDashing): Spedometer.text = str(int(abs(SpinDashCharge))) + "m/s";
	else: Spedometer.text = str(int(abs(c_Vel.z))) + "m/s";
	PlayAnimation(c_Vel,isOnGround)
	CameraZoom(abs(self.linear_velocity.z))
	
	if(Rolling or !isOnGround or SpinDashing): CollisionBody.shape.height = 1;
	else: CollisionBody.shape.height = 1.25;
	
	if(justSpun): 
		SpinDashing = false
		SpinDashCharge = 0
	
	""" GROUND ANGLEING
	if(isOnGround): 
		var xform = global_transform
		xform.basis.y = GroundCheck.get_collision_normal()
		xform.basis.x = -xform.basis.z.cross(GroundCheck.get_collision_normal())
		xform.basis = xform.basis.orthonormalized()
		MeshHolder.global_transform = xform;
		$Forward.global_transform = xform;
	"""
	pass
