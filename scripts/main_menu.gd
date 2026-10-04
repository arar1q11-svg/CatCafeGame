extends Control

const CREAM := Color("#fff5ec")
const PAPER := Color("#fffdfa")
const INK := Color("#55443b")
const ROSE := Color("#ec8f83")
const PEACH := Color("#f5c89a")
const MINT := Color("#a8c9ac")
const SAVE_PATH := "user://cat_cafe_save.cfg"
const ORDERS_PER_VISIT := 5
const POINTS_PER_ORDER := 10

const CATS := ["나비", "초코", "보리", "별이", "감자", "모찌"]
const MENU := ["따뜻한 우유", "딸기 라떼", "참치 샌드위치", "고양이 쿠키", "바닐라 라떼"]

var current_score := 0
var best_score := 0
var current_order := 0
var cat_name := ""
var recipe_name := ""
var choice_buttons: Array[Button] = []
var message_label: Label
var score_label: Label


func _ready() -> void:
	theme = preload("res://assets/themes/cat_cafe_theme.tres")
	randomize()
	_load_best_score()
	_show_title()


func _load_best_score() -> void:
	var save_data := ConfigFile.new()
	var error := save_data.load(SAVE_PATH)
	if error == ERR_FILE_NOT_FOUND:
		best_score = 0
	elif error != OK:
		push_error("최고 점수를 불러오지 못했습니다: %s" % error_string(error))
		best_score = 0
	else:
		best_score = int(save_data.get_value("scores", "best", 0))


func _save_best_score() -> void:
	var save_data := ConfigFile.new()
	var load_error := save_data.load(SAVE_PATH)
	if load_error != OK and load_error != ERR_FILE_NOT_FOUND:
		push_error("저장된 게임 데이터를 읽지 못했습니다: %s" % error_string(load_error))
		return

	save_data.set_value("scores", "best", best_score)
	var save_error := save_data.save(SAVE_PATH)
	if save_error != OK:
		push_error("최고 점수를 저장하지 못했습니다: %s" % error_string(save_error))


func _show_title() -> void:
	var content := _new_screen("나만의 포근한 카페를 열어봐요", 440)
	content.add_child(_make_label("=^.^=", 38, ROSE))
	content.add_child(_make_label("고양이 카페 키우기", 32, INK))
	content.add_child(_make_label("손님이 원하는 메뉴를 찾아 대접해요", 17, INK))

	var spacer := Control.new()
	spacer.custom_minimum_size.y = 12
	content.add_child(spacer)
	content.add_child(_make_label("주문 5개를 모두 받으면 오늘의 영업 끝!", 15, INK))
	content.add_child(_make_label("최고 기록  %d점" % best_score, 18, INK))

	var start_button := _make_button("카페 문 열기", ROSE)
	start_button.pressed.connect(_start_visit)
	content.add_child(start_button)

	content.add_child(_make_label("시간 제한 없이 천천히 골라 주세요", 14, INK))


func _start_visit() -> void:
	current_score = 0
	current_order = 0
	_show_order()


func _show_order(feedback: String = "손님의 주문을 골라 주세요.") -> void:
	var content := _new_screen("주문을 골라 손님을 기쁘게 해 주세요", 640)
	cat_name = CATS[randi_range(0, CATS.size() - 1)]
	recipe_name = MENU[randi_range(0, MENU.size() - 1)]
	choice_buttons.clear()

	content.add_child(_make_label("오늘의 카페", 29, INK))
	score_label = _make_label(
		"이번 방문  %d점     최고 기록  %d점" % [current_score, best_score],
		15,
		INK
	)
	content.add_child(score_label)
	content.add_child(
		_make_label(
			"손님 %d / %d   ·   %s 손님" % [current_order + 1, ORDERS_PER_VISIT, cat_name],
			18,
			ROSE
		)
	)
	content.add_child(_make_label("주문이에요!\n%s" % recipe_name, 25, INK))

	message_label = _make_label(feedback, 15, INK)
	message_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	content.add_child(message_label)

	var choices := _make_choices(recipe_name)
	for choice_index in range(choices.size()):
		var button := _make_button(
			choices[choice_index],
			[PEACH, MINT, ROSE][choice_index]
		)
		button.pressed.connect(_on_choice_pressed.bind(choices[choice_index]))
		choice_buttons.append(button)
		content.add_child(button)


func _make_choices(correct_choice: String) -> Array[String]:
	var choices: Array[String] = [correct_choice]
	var alternatives := MENU.duplicate()
	alternatives.erase(correct_choice)
	alternatives.shuffle()
	choices.append(alternatives[0])
	choices.append(alternatives[1])
	choices.shuffle()
	return choices


func _on_choice_pressed(choice: String) -> void:
	if choice != recipe_name:
		message_label.text = "앗, 그 메뉴가 아니에요. 주문을 다시 확인해 주세요!"
		return

	current_score += POINTS_PER_ORDER
	current_order += 1
	if current_order >= ORDERS_PER_VISIT:
		_finish_visit()
		return

	_show_order("잘했어요! 다음 손님이 기다리고 있어요.")


func _finish_visit() -> void:
	if current_score > best_score:
		best_score = current_score
		_save_best_score()
	_show_results()


func _show_results() -> void:
	var content := _new_screen("오늘의 영업이 끝났어요", 500)
	content.add_child(_make_label("오늘도 고생했어요!", 27, ROSE))
	content.add_child(_make_label("%d / %d 주문 완료" % [ORDERS_PER_VISIT, ORDERS_PER_VISIT], 17, INK))
	content.add_child(_make_label("오늘의 점수", 18, INK))
	content.add_child(_make_label("%d점" % current_score, 44, ROSE))
	content.add_child(_make_label("나의 최고 기록  %d점" % best_score, 19, INK))

	var replay_button := _make_button("다시 영업하기", ROSE)
	replay_button.pressed.connect(_start_visit)
	content.add_child(replay_button)

	var home_button := _make_button("처음 화면으로", PEACH)
	home_button.add_theme_color_override("font_color", INK)
	home_button.pressed.connect(_show_title)
	content.add_child(home_button)


func _new_screen(subtitle: String, minimum_height: float) -> VBoxContainer:
	for child in get_children():
		child.queue_free()

	var background := ColorRect.new()
	background.color = CREAM
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(background)

	var center := CenterContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	center.add_theme_constant_override("margin_left", 24)
	center.add_theme_constant_override("margin_right", 24)
	center.add_theme_constant_override("margin_top", 24)
	center.add_theme_constant_override("margin_bottom", 24)
	add_child(center)

	var card := PanelContainer.new()
	card.custom_minimum_size = Vector2(480, minimum_height)
	card.add_theme_stylebox_override("panel", _make_card_style())
	center.add_child(card)

	var content := VBoxContainer.new()
	content.add_theme_constant_override("separation", 18)
	card.add_child(content)

	content.add_child(_make_label(subtitle, 16, INK))
	return content


func _make_label(text: String, font_size: int, color: Color) -> Label:
	var label := Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", font_size)
	label.add_theme_color_override("font_color", color)
	return label


func _make_button(text: String, color: Color) -> Button:
	var button := Button.new()
	button.text = text
	button.custom_minimum_size.y = 60
	button.add_theme_font_size_override("font_size", 19)
	button.add_theme_color_override("font_color", Color.WHITE)
	button.add_theme_color_override("font_hover_color", Color.WHITE)
	button.add_theme_stylebox_override("normal", _make_button_style(color))
	button.add_theme_stylebox_override("hover", _make_button_style(color.darkened(0.08)))
	button.add_theme_stylebox_override("pressed", _make_button_style(color.darkened(0.16)))
	return button


func _make_card_style() -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = PAPER
	style.set_corner_radius_all(28)
	style.set_content_margin_all(26)
	return style


func _make_button_style(color: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = color
	style.set_corner_radius_all(18)
	style.set_content_margin_all(12)
	return style
