extends Control

func _ready() -> void:
	if !SettingsManager.get_setting("exactness"):
		$HealthLabel.hide()
		$HealthProgressBar.show()

func set_nickname(nickname: String) -> void:
	$NicknameLabel.text = nickname

mastersync func refresh_stats(health: float) -> void:
	if SettingsManager.get_setting("exactness"):
		$HealthLabel.text = var2str(health)
	else:
		$HealthProgressBar.value = health
