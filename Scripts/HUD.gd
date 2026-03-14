# script ini untuk HUD
extends Control

# mobil yang memiliki HUD ada di parent
onready var target_car_node = get_node("..")

# label KPH
onready var kph_value_node = get_node("KPHValue")

# label Gear
onready var gear_value_node = get_node("GearValue")

# label Time
onready var time_value_node = get_node("TimeValue")

var milisecond_passed = 0
var ms_val = 0
var s_val = 0
var m_val = 0

# saat ready
func _ready():
	# reset nilai-nilai di bawah ini
	milisecond_passed = 0
	ms_val = 0
	s_val = 0
	m_val = 0

func _process(delta):
	# akumulasikan delta time
	milisecond_passed += delta
	
	# convert kph ke string
	var actual_kph_string = "{str} KpH".format({
		"str": int(round(target_car_node.current_kph))
	})
	
	# convert gear ke string
	var actual_gear_string = "{str}".format({
		"str": target_car_node.current_gear
	})
	
	# convert time ke string
	var actual_time_string = "{minutes}:{seconds}:{ms}".format({
		"minutes": floor(milisecond_passed / 60),
		"seconds": int(floor(milisecond_passed)) % 60,
		"ms": int(floor(milisecond_passed * 1000.0)) % 1000
	})
	
	# masukkan nilai nilai di atas ke labelnya masing-masing
	kph_value_node.text = actual_kph_string
	gear_value_node.text = actual_gear_string
	time_value_node.text = actual_time_string
	
	
	#print(milisecond_passed)
