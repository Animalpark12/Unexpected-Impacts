extends CanvasLayer

@onready var texture_progress_bar: TextureProgressBar = $TextureProgressBar

func update_health_bar(health: int):
	texture_progress_bar.value = health
