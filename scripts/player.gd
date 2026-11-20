extends CharacterBody3D

const WALK_SPEED = 7.0
const RUN_SPEED = 12.0
const JUMP_VELOCITY = 6.5
const MOUSE_SENSITIVITY = 0.003

var gravity = 18.0
var camera_pivot: Node3D
var camera: Camera3D

func _ready():
    _create_player_body()
    _create_camera()
    _create_hud()

func _create_player_body():
    var collision = CollisionShape3D.new()
    var shape = CapsuleShape3D.new()
    shape.radius = 0.42
    shape.height = 1.8
    collision.shape = shape
    collision.position.y = 0.9
    add_child(collision)

    var visual = MeshInstance3D.new()
    var mesh = CapsuleMesh.new()
    mesh.radius = 0.42
    mesh.height = 1.8
    visual.mesh = mesh
    visual.position.y = 0.9

    var material = StandardMaterial3D.new()
    material.albedo_color = Color(0.12, 0.36, 0.85)
    visual.material_override = material
    add_child(visual)

func _create_camera():
    camera_pivot = Node3D.new()
    camera_pivot.position = Vector3(0, 1.5, 0)
    add_child(camera_pivot)

    camera = Camera3D.new()
    camera.position = Vector3(0, 2.3, 6.5)
    camera.current = true
    camera.fov = 75
    camera_pivot.add_child(camera)
    camera.look_at(Vector3(0, 1.2, 0), Vector3.UP)

func _create_hud():
    var canvas = CanvasLayer.new()
    add_child(canvas)

    var label = Label.new()
    label.text = "STREET RUSH 3D\nWASD: MOVE | SHIFT: RUN\nSPACE: JUMP | MOUSE: LOOK\nCLICK: CAPTURE MOUSE | ESC: RELEASE"
    label.position = Vector2(20, 20)
    label.add_theme_font_size_override("font_size", 17)
    label.add_theme_color_override("font_color", Color.WHITE)
    canvas.add_child(label)

func _unhandled_input(event):
    if event is InputEventMouseButton and event.pressed:
        Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

    if event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

    if event is InputEventMouseMotion and Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
        camera_pivot.rotation.y -= event.relative.x * MOUSE_SENSITIVITY
        camera_pivot.rotation.x -= event.relative.y * MOUSE_SENSITIVITY
        camera_pivot.rotation.x = clamp(
            camera_pivot.rotation.x,
            deg_to_rad(-50),
            deg_to_rad(40)
        )

func _physics_process(delta):
    if not is_on_floor():
        velocity.y -= gravity * delta

    if Input.is_key_pressed(KEY_SPACE) and is_on_floor():
        velocity.y = JUMP_VELOCITY

    var move_x = (
        float(Input.is_key_pressed(KEY_D))
        - float(Input.is_key_pressed(KEY_A))
    )

    var move_forward = (
        float(Input.is_key_pressed(KEY_W))
        - float(Input.is_key_pressed(KEY_S))
    )

    var direction = (
        camera_pivot.global_basis.x * move_x
        - camera_pivot.global_basis.z * move_forward
    )

    direction.y = 0
    direction = direction.normalized()

    var speed = WALK_SPEED
    if Input.is_key_pressed(KEY_SHIFT):
        speed = RUN_SPEED

    if direction.length() > 0:
        velocity.x = direction.x * speed
        velocity.z = direction.z * speed
    else:
        velocity.x = move_toward(velocity.x, 0, WALK_SPEED * 5 * delta)
        velocity.z = move_toward(velocity.z, 0, WALK_SPEED * 5 * delta)

    move_and_slide()
