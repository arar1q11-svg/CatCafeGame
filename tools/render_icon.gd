extends SceneTree


func _initialize() -> void:
	call_deferred("_render_icon")


func _render_icon() -> void:
	var texture := load("res://assets/images/cat_cafe_icon.svg") as Texture2D
	if texture == null:
		push_error("Could not load the cafe icon SVG.")
		quit(1)
		return

	var image := texture.get_image()
	image.resize(512, 512, Image.INTERPOLATE_LANCZOS)
	var output_path := ProjectSettings.globalize_path("res://assets/images/cat_cafe_icon.png")
	var error := image.save_png(output_path)
	if error != OK:
		push_error("Could not save the cafe icon PNG: %s" % error_string(error))
		quit(1)
		return

	print("Created %s (512x512)." % output_path)
	quit()
