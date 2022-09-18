extends Object

# name - имя, number - число, power - сила, rate - скорострельность, recoil - отдача
var name: String
var number: int
var power: float
var rate: float
var recoil: float
var shot_sound: AudioStream

func _init(var name: String, var number: int, var power: float, var rate: float, var recoil: float, var shot_sound: AudioStream):
	self.name = name
	self.number = number
	self.power = power
	self.rate = rate
	self.recoil = recoil
	self.shot_sound = shot_sound
