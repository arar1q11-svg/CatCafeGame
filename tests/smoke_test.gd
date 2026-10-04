extends SceneTree


func _initialize() -> void:
	call_deferred("_run_tests")


func _run_tests() -> void:
	var packed_scene := load("res://scenes/main_menu.tscn") as PackedScene
	assert(packed_scene != null, "The main menu scene should load.")

	var game := packed_scene.instantiate()
	root.add_child(game)
	await process_frame
	assert(_contains_text(game, "고양이 카페 키우기"), "The title screen should be shown.")

	game.call("_start_visit")
	assert(int(game.get("current_order")) == 0, "A visit should start with the first order.")
	assert(int(game.get("current_score")) == 0, "A visit should start with zero points.")

	var recipe: String = game.get("recipe_name")
	var buttons: Array = game.get("choice_buttons")
	for button in buttons:
		if button.text != recipe:
			button.pressed.emit()
			break

	var feedback: Label = game.get("message_label")
	assert(feedback.text.contains("다시 확인"), "An incorrect drink should offer another try.")
	assert(int(game.get("current_order")) == 0, "An incorrect drink should not advance the order.")
	game.set("best_score", 100)

	for order_index in range(5):
		recipe = game.get("recipe_name")
		buttons = game.get("choice_buttons")
		var served := false
		for button in buttons:
			if button.text == recipe:
				button.pressed.emit()
				served = true
				break

		assert(served, "Every order should include its correct drink.")
		assert(int(game.get("current_score")) == (order_index + 1) * 10)

		if order_index < 4:
			assert(int(game.get("current_order")) == order_index + 1)
			assert(not _contains_text(game, "오늘의 영업이 끝났어요"))

	assert(_contains_text(game, "오늘의 영업이 끝났어요"), "The results screen should follow the final order.")
	assert(_contains_text(game, "50점"), "The results screen should show the visit score.")

	var replay := _find_button(game, "다시 영업하기")
	assert(replay != null, "The results screen should offer another visit.")
	replay.pressed.emit()
	assert(int(game.get("current_order")) == 0, "Starting another visit should reset the order.")
	assert(int(game.get("current_score")) == 0, "Starting another visit should reset the score.")

	print("PASS: title, retry, five orders, score, results, and replay.")
	quit()


func _contains_text(node: Node, expected_text: String) -> bool:
	if node is Label and (node as Label).text.contains(expected_text):
		return true

	for child in node.get_children():
		if _contains_text(child, expected_text):
			return true

	return false


func _find_button(node: Node, expected_text: String) -> Button:
	if node is Button and (node as Button).text == expected_text:
		return node as Button

	for child in node.get_children():
		var match := _find_button(child, expected_text)
		if match != null:
			return match

	return null
