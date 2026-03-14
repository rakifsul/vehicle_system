# script untuk scene SelectCar.tscn, untuk memilih jenis mobil.

extends Control

# daftar sprite dari masing-masing mobil
export(Array, String) var car_sprite_name = []

# scene selanjutnya
export var next_scene_path = "res://Scenes/SelectLevel.tscn"

# referensi ke node di bawah ini
onready var car_sprite = get_node("CarSprite")

# index sprite name
var car_sprite_name_index = 0

func _ready():
	# set texture ke sprite mobil
	car_sprite.set_texture(load("res://Textures/" + car_sprite_name[car_sprite_name_index] + ".png"))

func _on_Prev_pressed():
	# ke sebelumnya
	do_prev()
	
	# set texture ke sprite mobil
	car_sprite.set_texture(load("res://Textures/" + car_sprite_name[car_sprite_name_index] + ".png"))

func _on_Next_pressed():
	# ke selanjutnya
	do_next()
	
	# set texture ke sprite mobil
	car_sprite.set_texture(load("res://Textures/" + car_sprite_name[car_sprite_name_index] + ".png"))

func do_next():
	car_sprite_name_index += 1
	if car_sprite_name_index >= car_sprite_name.size():
		car_sprite_name_index = 0;
	
func do_prev():
	car_sprite_name_index -= 1
	if car_sprite_name_index <= -1:
		car_sprite_name_index = car_sprite_name.size() - 1

# pilih mobil ini
func _on_ChooseThisCar_pressed():
	Globals.chosen_car = car_sprite_name[car_sprite_name_index]
	
	get_tree().change_scene(next_scene_path)
