# script untuk mengendalikan mobil.
# sangat sulit untuk dijelaskan.
# jika ada istilah yang kurang jelas, harap diterjemahkan sendiri.

extends VehicleBody

# sudut steering maksimum
export var max_steer_angle = 40

# engine force maksimum
export var max_engine_force = 200.0

# brake force maksimum
export var max_brake_force = 200.0

# gear ratios maju
export (Array) var forward_gear_ratios = [ 3.70, 3.03, 2.61, 2.35, 1.15, 1.0 ] 

# gear ratios mundur
export (float) var backward_gear_ratio = -2.8

# gear ratio terakhir
export (float) var last_gear_ratio = 3.40

# waktu pergantian gear
export var gear_changing_time = 0.5

# engine rpm maksimum
export (float) var max_engine_rpm = 6000.0

# power curve
export (Curve) var engine_power_curve = null

export(NodePath) var wheel_reference_path
var wheel_reference = null
export(NodePath) var engine_audio_path
var engine_audio = null

var current_kph = 0.0
var calculated_rpm = 0.0
var calculated_power = 0.0
var calculated_engine_force = 0.0
var current_rpm_factor = 0.0
var calculated_rpm_factor = 0.0
var current_gear = 0
var clutch_factor = 1.0
var current_speed = 0.0
var steer_input_val = 0.0
var throttle_input_val = 0.0
var brake_input_val = 0.0
var real_throttle_value = 0.0
var is_gear_down_just_pressed = false
var is_gear_up_just_pressed = false

func _ready():
	# referensi ke node di bawah ini
	wheel_reference = get_node(wheel_reference_path)
	engine_audio = get_node(engine_audio_path)

func _process(_delta):
	# kalkulasi gear
	calculate_gear()
	
	# perbarui info seputar mobil ini
	update_info(_delta)

func _physics_process(_delta):
	# kecepatan saat ini
	current_speed = linear_velocity.length()
	
	# reset nilai-nilai di bawah ini
	steer_input_val = 0.0
	throttle_input_val = 0.0
	brake_input_val = 0.0
	
	# tangani input
	if Input.is_action_pressed("forward"):
		throttle_input_val = 1.0
	if Input.is_action_pressed("brake"):
		brake_input_val = 1.0
	if Input.is_action_pressed("left"):
		steer_input_val = 1.0
	elif Input.is_action_pressed("right"):
		steer_input_val = -1.0
	is_gear_down_just_pressed = Input.is_action_just_pressed("gear-down")
	is_gear_up_just_pressed = Input.is_action_just_pressed("gear-up")
	
	real_throttle_value = lerp(real_throttle_value, throttle_input_val, 5.0 * _delta)
	
	# kalkulasi engine force
	calculate_engine_force()
	
	# kalkulasi brake
	calculate_brake()
	
	# kalkulasi audio
	calculate_audio()
	
	current_rpm_factor = calculated_rpm_factor
	current_kph = current_speed * 5.79364
	
	# kalkulasi steering
	calculate_steering(_delta)

func calculate_engine_force():
	# di sini, bayangkan cara kerja mesin mobil.
	# sangat sulit dijelaskan.
	
	var wheel_rotation_speed = 30.0 * current_speed / (PI * wheel_reference.wheel_radius)
	var neutral_rpm = real_throttle_value * max_engine_rpm
	var reverse_rpm = wheel_rotation_speed * clutch_factor * last_gear_ratio * -backward_gear_ratio
	var forward_rpm = wheel_rotation_speed * clutch_factor * last_gear_ratio * forward_gear_ratios[current_gear - 1]
	
	if current_gear == 0 || clutch_factor == 0.0:
		calculated_rpm = neutral_rpm
		calculated_rpm_factor = clamp(calculated_rpm / max_engine_rpm, 0.0, 1.0)
		calculated_power = engine_power_curve.interpolate_baked(clamp((neutral_rpm)/max_engine_rpm, 0.0, 1.0))
		calculated_engine_force = 0.0
		engine_force = calculated_engine_force
		return
		
	if current_gear == -1:
		calculated_rpm = reverse_rpm
		calculated_rpm_factor = clamp(calculated_rpm / max_engine_rpm, 0.0, 1.0)
		calculated_power = engine_power_curve.interpolate_baked(clamp((reverse_rpm)/max_engine_rpm, 0.0, 1.0))
		calculated_engine_force = -1.0 * real_throttle_value * calculated_power * backward_gear_ratio * last_gear_ratio * max_engine_force
		engine_force = calculated_engine_force
		return
	elif current_gear > 0 and current_gear <= forward_gear_ratios.size():
		calculated_rpm = forward_rpm
		calculated_rpm_factor = clamp(calculated_rpm / max_engine_rpm, 0.0, 1.0)
		calculated_power = engine_power_curve.interpolate_baked(clamp((forward_rpm)/max_engine_rpm, 0.0, 1.0))
		calculated_engine_force = -1.0 * real_throttle_value * calculated_power * forward_gear_ratios[current_gear - 1] * last_gear_ratio * max_engine_force
		engine_force = calculated_engine_force
		return
	else:
		calculated_rpm = 0
		calculated_rpm_factor = clamp(calculated_rpm / max_engine_rpm, 0.0, 1.0)
		calculated_power = engine_power_curve.interpolate_baked(clamp((0.0)/max_engine_rpm, 0.0, 1.0))
		calculated_engine_force = 0.0
		engine_force = calculated_engine_force
		return

func calculate_brake():
	# kalkulasi brake
	if brake_input_val > 0.0:
		engine_force = 0.0
	
	# ingat pedal rem tidak langsung maksimum saat diinjak.
	brake = brake_input_val * max_brake_force

func calculate_audio():	
	# suara mesin tergantung rpm
	engine_audio.pitch_scale = 1.0 + calculated_rpm_factor * 4.0

func calculate_steering(_delta):
	# steer mobil tidak langsung maksimum kiri maupun kanan, tergantung berapa besar kita menggerakkannya
	steering = lerp(steering, steer_input_val * deg2rad(max_steer_angle), 5.0 * _delta)

func gear_down():
	# gear turun
	if current_gear > -1:
		current_gear = current_gear - 1
		yield(get_tree().create_timer(gear_changing_time),"timeout")

func gear_up():
	# gear naik
	if current_gear < forward_gear_ratios.size():
		current_gear = current_gear + 1
		yield(get_tree().create_timer(gear_changing_time),"timeout")

# clutch adalah kopling, mobil ini manual
func press_clutch():
	clutch_factor = 0.0

func release_clutch():
	clutch_factor = 1.0
	
func update_info(_delta):
	pass

func calculate_gear():
	# bayangkan saat kita ganti gear di mobil manual.
	if is_gear_down_just_pressed:
		press_clutch()
		gear_down()
		release_clutch()
	elif is_gear_up_just_pressed:
		press_clutch()
		gear_up()
		release_clutch()
	else:
		release_clutch()
