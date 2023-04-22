extends RigidBody3D

#Editable Vars
const SpinSpeed = 16;
const GroundSpeed = 16;
const AirSpeed = 8;
const SlowDownPercentage = 0.75;
const AirControlPercentage = 0.6;
const SpeedForSuper = 120;
const CameraFOVSpeed = 0.15;

var CheckpointLocation:Vector3
var facingForward = true;
var Rolling = false;
var ForceGravity = 0;

var SonicMesh:Node3D;
var MeshHolder:Node3D;
var GroundCheck:RayCast3D;
var Animator:AnimationPlayer;
var Spedometer:RichTextLabel;
var RingsCounter:RichTextLabel;
var CollisionBody:CollisionShape3D;
var TotalRings:int = 0

var SpinDashing:bool = false
var SpinDashCharge = 0
var Invinciblity = 5;

@export var SpeedMS:int = 0;
@onready var RingPrefab:Resource = load("res://Prefabs/SonicDroppedRing.tscn")

# EFFECTS
@onready var SpeedBoostVFX:Resource = load("res://VFX/SpeedBoost.tscn")

func onCheckpoint(pos):
	CheckpointLocation = pos

func Rebounce(velocity):
	self.linear_velocity = velocity

func onRing():
	if(abs(self.linear_velocity.z) > 0 and Rolling):
		var speed = clamp((1-clamp(self.linear_velocity.z/80,0,1)) * 5,-5,5);
		if(abs(self.linear_velocity.z) <= 30):
			if(facingForward): self.linear_velocity.z += speed;
			else: self.linear_velocity.z -= speed;
	TotalRings += 1

func takeDamage(goThruRoll,instaKill = false,ringLose=false) -> bool:
	if(!instaKill): if(!goThruRoll and Rolling) or Invinciblity > 0: return false
	if(TotalRings <= 0 or instaKill):
		$SoundFXs/Death.play()
		if(ringLose):
			if(TotalRings > 100): TotalRings = 100
			for i in TotalRings:
				var newRing:RigidBody3D = RingPrefab.instantiate()
				newRing.position = self.position
				get_tree().current_scene.add_child(newRing)
				TotalRings -= 1;
		self.linear_velocity = Vector3()
		self.position = CheckpointLocation
		TotalRings = 0
		return true
	else:
		Invinciblity = 5
		$SoundFXs/RingDamage.play()
		if(TotalRings > 100): TotalRings = 100
		for i in TotalRings:
			var newRing:RigidBody3D = RingPrefab.instantiate()
			newRing.position = self.position
			get_tree().current_scene.add_child(newRing)
			TotalRings -= 1;
		return true

func _ready():
	SonicMesh = get_node("MeshHolder/SonicMesh");
	GroundCheck = get_node("GroundCheck")
	Animator = get_node("MeshHolder/SonicMesh/AnimationPlayer")
	Spedometer = get_node("HUD/Speed")
	MeshHolder = get_node("MeshHolder")
	CollisionBody = get_node("Collision")
	RingsCounter = get_node("HUD/Rings")
	CheckpointLocation = self.position
	$VFX/SpeedBurst.emitting = false
	pass # Replace with function body.

# process velocity and play animation based on that
func PlayAnimation(velocity,OnGround) -> void:
	var isFRRolling = (Rolling and abs(velocity.z) > 0.5)
	if(OnGround and !isFRRolling and !SpinDashing):
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

var levelEnded:bool = false
func onLevelEnded() -> int:
	levelEnded = true
	$Camera3D.reparent(get_tree().current_scene)
	remove_child($HUD)
	return TotalRings

func CameraZoom(speed):
	$Camera3D.fov = lerp($Camera3D.fov,75 * clamp((speed / 25) + 0.2,0.8,1.6),CameraFOVSpeed)
	$Camera3D.size = lerp($Camera3D.size,15 * clamp((speed / 25) + 0.2,0.8,1.6),CameraFOVSpeed)
	if(Input.is_action_just_pressed("CameraSwap")):
		if $Camera3D.projection == $Camera3D.PROJECTION_ORTHOGONAL:
			$Camera3D.projection = $Camera3D.PROJECTION_PERSPECTIVE
		else:
			$Camera3D.projection = $Camera3D.PROJECTION_ORTHOGONAL

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#Restart Level
	if(!levelEnded): $HUD/Timer.text = "TIME: " + $"/root/SpeedrunTimer".TimeToString();
	Invinciblity -= delta
	if(Input.is_action_pressed("Restart")): takeDamage(false,true,true)
		
	var MoveInput:Vector2 = Input.get_vector("Left","Right","Backward","Forward");
	var isOnGround:bool = GroundCheck.is_colliding() or $GroundCheck2.is_colliding() or $GroundCheck3.is_colliding()

	var justSpun = false
	if(SpinDashing and (!Input.is_action_pressed("Jump") or !Input.is_action_pressed("Backward")) and SpinDashCharge >= 5):
		#Was Spindashing
		if(facingForward): self.linear_velocity.z += SpinDashCharge
		else: self.linear_velocity.z -= SpinDashCharge
		$SoundFXs/Boost.play()
		var Boost = SpeedBoostVFX.instantiate()
		Boost.position = self.position
		Boost.rotation_degrees.y = SonicMesh.rotation_degrees.y
		print(Boost.rotation_degrees.y)
		get_tree().current_scene.add_child(Boost)
		justSpun = true
		SpinDashing = false
	
	SpinDashing = isOnGround and Input.is_action_pressed("Backward") and (SpinDashing or Input.is_action_pressed("Jump")) and abs(self.linear_velocity.z) <= 0.5
	if(SpinDashing): 
		if(SpinDashCharge == 0 and Input.is_action_pressed("Backward") and Input.is_action_pressed("Jump")): $SoundFXs/Spin.play()
		var speedMulti = (1 - clamp(SpinDashCharge/400,0,1))
		SpinDashCharge += (speedMulti*speedMulti) * 25 * delta
		SpinDashCharge = clamp(SpinDashCharge,0,100)
		$VFX/SpeedBurst.emitting = true
		$VFX/SpeedBurst.rotation_degrees.y = SonicMesh.rotation_degrees.y
	else:
		SpinDashCharge = 0
		$VFX/SpeedBurst.emitting = false
	
	var c_Vel = self.linear_velocity;
	
	Rolling = (isOnGround and Input.is_action_pressed("Backward") and int(abs(c_Vel.z)) > 0) or ($RoofCheck.is_colliding()) or ($RoofCheck2.is_colliding()) or ($RoofCheck3.is_colliding())
	
		#Flip Character Based On facingForward
	if(facingForward): SonicMesh.rotation_degrees.y = 0;
	else: SonicMesh.rotation_degrees.y = 180;
	
	var XInput = MoveInput.x;
	if(!levelEnded):
		if(abs(MoveInput.x) > 0):
			if((c_Vel.z > 2 and MoveInput.x <= -0.5) or (c_Vel.z < -2 and MoveInput.x >= 0.5)):
				XInput = -((c_Vel.z * SlowDownPercentage) * 2);
				if(!$SoundFXs/Skid.playing and isOnGround): $SoundFXs/Skid.play()
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
	
	if isOnGround and (Input.is_action_just_pressed("Jump") or Input.is_action_just_pressed("Forward")) and !Rolling and !Input.is_action_pressed("Backward"):
		c_Vel.y = 8 * clamp((abs(c_Vel.z) / 100) + 1,1,1.25);
		$SoundFXs/Jump.play()
	elif(!isOnGround and Input.is_action_pressed("Jump")):
		c_Vel.y -= 9.8 * delta;
	elif(!isOnGround and Input.is_action_pressed("Backward")):
		c_Vel.y -= 16.8 * delta;
	elif(!isOnGround):
		c_Vel.y -= 12.8 * delta;
	
	c_Vel.z = clamp(c_Vel.z,-400,400)
	if(!levelEnded):
		if(!SpinDashing and !justSpun):
			if(isOnGround and !Rolling): 
				if(abs(c_Vel.z) <= 0.05): c_Vel.z = c_Vel.z * 2;
				self.linear_velocity = c_Vel;
			else:
				self.linear_velocity.y = c_Vel.y;
				self.linear_velocity.z += (XInput * delta * AirSpeed);
		elif(justSpun):
			self.linear_velocity.z += SpinDashCharge
	else:
		var dir = 1 if facingForward else -1
		self.linear_velocity.z += (dir * GroundSpeed * delta);
	
	self.linear_velocity.x = 0
	
	# Visuals
	if(SpinDashing): Spedometer.text = str(int(abs(SpinDashCharge))) + "m/s";
	else: Spedometer.text = str(int(abs(c_Vel.z))) + "m/s";
	if(!levelEnded): RingsCounter.text = "Rings: " + str(TotalRings)
	PlayAnimation(c_Vel,isOnGround)
	
	if(!levelEnded): CameraZoom(abs(self.linear_velocity.z))
	
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
