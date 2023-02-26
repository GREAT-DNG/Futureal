extends Node

# Описание оружий: 
# name - имя
# id - идентификатор
# power - сила
# rate - скорострельность
# reload_time - время перезарядки
# recoil - отдача
# bullets - пули
# loaded_bullets - заряжанные пули
# clip_size - емкость магазина
# is_reloaded - перезаряженность
# is_automatic - автоматичеСКОСТЬ :/

# Пистолет
var gun0 = {
	"name": "Desert Eagle",
	"id": 0,
	"power": 0.8,
	"rate": 0.2,
	"reload_time": 1.21,
	"recoil": 5,
	"bullets": 21,
	"loaded_bullets": 7,
	"clip_size": 7,
	"is_reloaded": true,
	"is_automatic": false}
# Полуавтоматы
var gun1 = {
	"name": "Mac-10",
	"id": 1,
	"power": 0.5,
	"rate": 0.05,
	"reload_time": 1.11,
	"recoil": 10,
	"bullets": 90,
	"loaded_bullets": 30,
	"clip_size": 30,
	"is_reloaded": true,
	"is_automatic": true}
var gun2 = {
	"name": "HK MP5",
	"id": 2,
	"power": 0.6,
	"rate": 0.05,
	"reload_time": 1.45,
	"recoil": 15,
	"bullets": 90,
	"loaded_bullets": 30,
	"clip_size": 30,
	"is_reloaded": true,
	"is_automatic": true}
# Автоматы
var gun3 = {
	"name": "AK47",
	"id": 3,
	"power": 1.1,
	"rate": 0.1,
	"reload_time": 1.67,
	"recoil": 20,
	"bullets": 90,
	"loaded_bullets": 30,
	"clip_size": 30,
	"is_reloaded": true,
	"is_automatic": true} 
var gun4 = {
	"name": "M4A1",
	"id": 4,
	"power": 0.9,
	"rate": 0.08,
	"reload_time": 1.16,
	"recoil": 25,
	"bullets": 90,
	"loaded_bullets": 30,
	"clip_size": 30,
	"is_reloaded": true,
	"is_automatic": true}
# Супермегаоружие
var gun5 = {
	"name": "Benelli M4 Super 90",
	"id": 5,
	"power": 1.5,
	"rate": 1,
	"reload_time": 1.07,
	"recoil": 100,
	"bullets": 16,
	"loaded_bullets": 8,
	"clip_size": 8,
	"is_reloaded": true,
	"is_automatic": false}
var gun6 = {
	"name": "M249 SAW",
	"id": 6,
	"power": 1,
	"rate": 0.08,
	"reload_time": 3.43,
	"recoil": 30,
	"bullets": 100,
	"loaded_bullets": 100,
	"clip_size": 100,
	"is_reloaded": true,
	"is_automatic": true}

var guns = [gun0, gun1, gun2, gun3, gun4, gun5, gun6]

# Возвращает данные об оружии
func get_gun(var gun_id):
	return guns[gun_id]
	
func get_gun_sprite(var gun_id):
	return load("res://Sprites/Guns/Gun" + var2str(gun_id) + ".png")
	
func get_gun_shot_sound(var gun_id):
	return load("res://Audios/Guns/" + var2str(gun_id) + " Shot.wav")
	
func get_gun_reload_sound(var gun_id):
	return load("res://Audios/Guns/" + var2str(gun_id) + " Reload.wav")
	
