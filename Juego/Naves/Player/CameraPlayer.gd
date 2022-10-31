# CameraPlayer.gd

class_name CameraPlayer
extends CamaraJuego

## Variables Export
export var variacion_zoom: float = 0.1
export var zoom_minimo: float = 0.6
export var zoom_maximo: float = 2.0

## Setters y Getters
func set_puede_hacer_zoom(puede: bool) -> void:
	puede_hacer_zoom = puede

## Metodos
func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("zoom_acercar"):
		controlar_zoom(-variacion_zoom)
	if event.is_action_pressed("zoom_alejar"):
		controlar_zoom(variacion_zoom)

## Metodos Custom
func controlar_zoom(mod_zoom: float) -> void:
	print (zoom)
	var zoom_x = clamp(zoom.x + mod_zoom, zoom_minimo, zoom_maximo)
	var zoom_y = clamp(zoom.y + mod_zoom, zoom_minimo, zoom_maximo)
	print (zoom_x, zoom_y)
	zoom_suavizado(zoom_x, zoom_y, 0.15)

func zoom_suavizado(nuevo_zoom_x: float, nuevo_zoom_y: float, tiempo_transicion: float) -> void:
	tween_zoom.interpolate_property(
		self,
		"zoom",
		zoom,
		Vector2(nuevo_zoom_x, nuevo_zoom_y),
		tiempo_transicion,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	tween_zoom.start()

#func devolver_zoom_original() -> void:
#	print ("NO ZOOM player")
#	puede_hacer_zoom = false
#	zoom_suavizado(zoom_original.x, zoom_original.y, 1.5)
