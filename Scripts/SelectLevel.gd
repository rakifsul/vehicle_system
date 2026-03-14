# script untuk scene SelectLevel.tscn, untuk memilih jenis level.

extends Control

# daftar sprite level
export(Array, String) var level_sprite_name = []

# scene selanjutnya
export var next_scene_path = "res://Scenes/Level001.tscn"

# referensi ke node di bawah ini
onready var level_sprite = get_node("LevelSprite")

# index sprite level
var level_sprite_name_index = 0

func _ready():
	# set texture ke sprite
	level_sprite.set_texture(load("res://Textures/" + level_sprite_name[level_sprite_name_index] + ".png"))

func _on_Prev_pressed():
	# ke sebelumnya
	do_prev()
	
	# set texture ke sprite
	level_sprite.set_texture(load("res://Textures/" + level_sprite_name[level_sprite_name_index] + ".png"))

func _on_Next_pressed():
	# ke selanjutnya
	do_next()
	
	# set texture ke sprite
	level_sprite.set_texture(load("res://Textures/" + level_sprite_name[level_sprite_name_index] + ".png"))

func do_next():
	level_sprite_name_index += 1
	if level_sprite_name_index >= level_sprite_name.size():
		level_sprite_name_index = 0;

func do_prev():
	level_sprite_name_index -= 1
	if level_sprite_name_index <= -1:
		level_sprite_name_index = level_sprite_name.size() - 1

# pilih level ini
func _on_ChooseThisLevel_pressed():
	Globals.chosen_level = level_sprite_name[level_sprite_name_index]
	
	get_tree().change_scene("res://Scenes/" + Globals.chosen_level + ".tscn")
