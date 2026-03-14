# ini adalah script yang mengatur End.tscn atau ending scene.

extends Control

# scene selanjutnya
export var next_scene_path = "res://Scenes/StartMenu.tscn"

# saat ready
func _ready():
	# tampilkan kursor mouse
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

# saat tombol restart diklik
func _on_Restart_pressed():
	# ganti scene ke next_scene_path
	get_tree().change_scene(next_scene_path)
