extends CharacterBody3D

var travel_axis := Vector3.RIGHT
var travel_direction := 1.0
var walking_speed := 1.5
var road_limit := 110.0
var clothing_color := Color(0.8, 0.5, 0.2)

func _ready():
    collision_layer = 4
    collision_mask = 1
    _create_person()

func _create_person():
    var collision = CollisionShape3D.new()
    var shape = CapsuleShape3D.new()
    shape.radius = 0.3
    shape.height = 1.65
    collision.shape = shape
    collision.position.y = 0.85
    add_child(collision)

    var body = MeshInstance3D.new()
    var capsule = CapsuleMesh.new()
    capsule.radius = 0.3
    capsule.height = 1.65
    body.mesh = capsule
    body.position.y = 0.85

    var mat = StandardMaterial3D.new()
    mat.albedo_color = clothing_color
    body.material_override = mat
    add_child(body)

func _physics_process(_delta):
    velocity = travel_axis * travel_direction * walking_speed
    move_and_slide()

    if travel_axis.x != 0:
        if global_position.x > road_limit:
            global_position.x = -road_limit
        elif global_position.x < -road_limit:
            global_position.x = road_limit
    else:
        if global_position.z > road_limit:
            global_position.z = -road_limit
        elif global_position.z < -road_limit:
            global_position.z = road_limit
