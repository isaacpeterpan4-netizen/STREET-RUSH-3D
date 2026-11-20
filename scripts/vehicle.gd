extends CharacterBody3D

const MAX_SPEED = 27.0
const REVERSE_SPEED = 10.0
const ACCELERATION = 17.0
const BRAKING = 30.0
const FRICTION = 8.0
const STEERING_SPEED = 1.65
const GRAVITY = 20.0

var current_speed := 0.0
var driver: CharacterBody3D
var driving_camera: Camera3D
var speed_label: Label
var wheels: Array[MeshInstance3D] = []

func _ready():
    add_to_group("drivable_vehicle")
    _create_vehicle_body()
    _create_wheels()
    _create_camera()
    _create_speedometer()

func _create_vehicle_body():
    var collision = CollisionShape3D.new()
    var shape = BoxShape3D.new()
    shape.size = Vector3(1.9, 1.2, 3.8)
    collision.shape = shape
    collision.position.y = 0.7
    add_child(collision)

    _add_box(Vector3(2.0, 0.65, 4.0), Vector3(0, 0.8, 0), Color(0.78, 0.08, 0.055))
    _add_box(Vector3(1.55, 0.75, 1.9), Vector3(0, 1.45, -0.15), Color(0.12, 0.2, 0.27))
    _add_box(Vector3(1.7, 0.12, 0.12), Vector3(0, 0.9, -2.02), Color(1.0, 0.9, 0.55))
    _add_box(Vector3(1.7, 0.12, 0.12), Vector3(0, 0.9, 2.02), Color(0.9, 0.03, 0.02))

func _add_box(size: Vector3, offset: Vector3, color: Color):
    var visual = MeshInstance3D.new()
    var mesh = BoxMesh.new()
    mesh.size = size
    visual.mesh = mesh
    visual.position = offset

    var material = StandardMaterial3D.new()
    material.albedo_color = color
    material.metallic = 0.3
    material.roughness = 0.4
    visual.material_override = material
    add_child(visual)

func _create_wheels():
    for x in [-1.0, 1.0]:
        for z in [-1.25, 1.25]:
            var wheel = MeshInstance3D.new()
            var mesh = CylinderMesh.new()
            mesh.top_radius = 0.42
            mesh.bottom_radius = 0.42
            mesh.height = 0.25
            wheel.mesh = mesh
            wheel.position = Vector3(x, 0.42, z)
            wheel.rotation.z = deg_to_rad(90)

            var material = StandardMaterial3D.new()
            material.albedo_color = Color(0.035, 0.035, 0.04)
            wheel.material_override = material
            add_child(wheel)
            wheels.append(wheel)

func _create_camera():
    driving_camera = Camera3D.new()
    driving_camera.position = Vector3(0, 4.5, 8.5)
    driving_camera.fov = 75
    add_child(driving_camera)
    driving_camera.look_at(Vector3(0, 1.0, -3.0), Vector3.UP)
    driving_camera.current = false

func _create_speedometer():
    var canvas = CanvasLayer.new()
    canvas.name = "VehicleHUD"
    add_child(canvas)

    speed_label = Label.new()
    speed_label.position = Vector2(25, 25)
    speed_label.add_theme_font_size_override("font_size", 25)
    speed_label.add_theme_color_override("font_color", Color.WHITE)
    speed_label.text = "STREET RUSH 3D"
    canvas.add_child(speed_label)
    canvas.visible = false

func enter_vehicle(player: CharacterBody3D):
    if driver != null:
        return

    driver = player
    driver.hide()
    driver.set_physics_process(false)

    var player_camera = driver.get_node_or_null("CameraPivot/Camera3D")
    if player_camera:
        player_camera.current = false

    driving_camera.current = true
    $VehicleHUD.visible = true
    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
    print("Entered vehicle")

func exit_vehicle():
    if driver == null:
        return

    var old_driver = driver
    driver = null

    old_driver.global_position = global_position + global_basis.x * 2.5
    old_driver.velocity = Vector3.ZERO
    old_driver.show()
    old_driver.set_physics_process(true)

    driving_camera.current = false

    var player_camera = old_driver.get_node_or_null("CameraPivot/Camera3D")
    if player_camera:
        player_camera.current = true

    $VehicleHUD.visible = false
    current_speed = 0.0
    velocity = Vector3.ZERO
    print("Exited vehicle")

func _unhandled_input(event):
    if driver != null and event is InputEventKey:
        if event.pressed and not event.echo and event.keycode == KEY_E:
            exit_vehicle()
            get_viewport().set_input_as_handled()

func _physics_process(delta):
    if driver == null:
        return

    var accelerating = Input.is_key_pressed(KEY_W)
    var braking = Input.is_key_pressed(KEY_S)
    var steering = (
        float(Input.is_key_pressed(KEY_A))
        - float(Input.is_key_pressed(KEY_D))
    )

    if accelerating:
        current_speed = move_toward(current_speed, MAX_SPEED, ACCELERATION * delta)
    elif braking:
        if current_speed > 0.5:
            current_speed = move_toward(current_speed, 0.0, BRAKING * delta)
        else:
            current_speed = move_toward(current_speed, -REVERSE_SPEED, ACCELERATION * 0.65 * delta)
    else:
        current_speed = move_toward(current_speed, 0.0, FRICTION * delta)

    if abs(current_speed) > 0.5:
        var steering_direction = 1.0 if current_speed > 0 else -1.0
        rotation.y += steering * STEERING_SPEED * steering_direction * delta * clamp(abs(current_speed) / 8.0, 0.25, 1.0)

    var forward = -global_basis.z
    velocity.x = forward.x * current_speed
    velocity.z = forward.z * current_speed

    if not is_on_floor():
        velocity.y -= GRAVITY * delta
    else:
        velocity.y = 0.0

    move_and_slide()

    speed_label.text = "STREET RUSH 3D\nSPEED: %03d KM/H\nWASD: DRIVE | E: EXIT" % int(abs(current_speed) * 3.6)
