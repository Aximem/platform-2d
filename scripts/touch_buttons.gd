extends CanvasLayer


func _on_left_touch_pressed() -> void:
	Input.action_press("move_left")

func _on_left_touch_released() -> void:
	Input.action_release("move_left")

func _on_right_touch_pressed() -> void:
	Input.action_press("move_right")

func _on_right_touch_released() -> void:
	Input.action_release("move_right")

func _on_top_touch_pressed() -> void:
	Input.action_press("climb")

func _on_top_touch_released() -> void:
	Input.action_release("climb")

func _on_bottom_touch_pressed() -> void:
	Input.action_press("descend")

func _on_bottom_touch_released() -> void:
	Input.action_release("descend")

func _on_jump_touch_pressed() -> void:
	Input.action_press("jump")

func _on_jump_touch_released() -> void:
	Input.action_release("jump")
