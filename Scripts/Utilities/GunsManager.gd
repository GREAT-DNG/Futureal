extends Node

const GUN0: Dictionary = {
	"name": "Desert Eagle",
	"id": 0,
	"power": 1.6,
	"rate": 0.1,
	"reload_time": 1.21,
	"recoil": 5,
	"bullets": 21,
	"loaded_bullets": 7,
	"clip_size": 7,
	"is_reloaded": true,
	"is_automatic": false,
	}
const GUN1: Dictionary = {
	"name": "Mac-10",
	"id": 1,
	"power": 0.8,
	"rate": 0.075,
	"reload_time": 1.11,
	"recoil": 10,
	"bullets": 90,
	"loaded_bullets": 30,
	"clip_size": 30,
	"is_reloaded": true,
	"is_automatic": true,
	}
const GUN2: Dictionary = {
	"name": "HK MP5",
	"id": 2,
	"power": 0.9,
	"rate": 0.08,
	"reload_time": 1.47,
	"recoil": 15,
	"bullets": 90,
	"loaded_bullets": 30,
	"clip_size": 30,
	"is_reloaded": true,
	"is_automatic": true,
	}
const GUN3: Dictionary = {
	"name": "AK47",
	"id": 3,
	"power": 1.5,
	"rate": 0.11,
	"reload_time": 0.82,
	"recoil": 25,
	"bullets": 90,
	"loaded_bullets": 30,
	"clip_size": 30,
	"is_reloaded": true,
	"is_automatic": true,
	}
const GUN4: Dictionary = {
	"name": "M4A1",
	"id": 4,
	"power": 0.97,
	"rate": 0.1,
	"reload_time": 1.16,
	"recoil": 22.5,
	"bullets": 90,
	"loaded_bullets": 30,
	"clip_size": 30,
	"is_reloaded": true,
	"is_automatic": true,
	}
const GUN5: Dictionary = {
	"name": "Benelli M4 Super 90",
	"id": 5,
	"power": 3.4,
	"rate": 0.75,
	"reload_time": 1.10,
	"recoil": 100,
	"bullets": 16,
	"loaded_bullets": 7,
	"clip_size": 7,
	"is_reloaded": true,
	"is_automatic": false,
	}
const GUN6: Dictionary = {
	"name": "M249 SAW",
	"id": 6,
	"power": 1.5,
	"rate": 0.1,
	"reload_time": 2.27,
	"recoil": 30,
	"bullets": 100,
	"loaded_bullets": 100,
	"clip_size": 100,
	"is_reloaded": true,
	"is_automatic": true,
	}

const GUNS: Array = [GUN0, GUN1, GUN2, GUN3, GUN4, GUN5, GUN6]

# Returns waepon data
func get_gun(gun_id: int) -> Dictionary:
	return GUNS[gun_id].duplicate()

func get_gun_sprite(gun_id: int) -> Resource:
	return load("res://Sprites/Guns/Gun" + var2str(gun_id) + ".png")

func get_gun_shot_sound(gun_id: int) -> Resource:
	return load("res://Audios/Guns/" + var2str(gun_id) + "/Shot.wav")

func get_gun_reload_sound(gun_id: int) -> Resource:
	return load("res://Audios/Guns/" + var2str(gun_id) + "/Reload.wav")
