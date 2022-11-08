#MiniMapa.gd
extends MarginContainer

## Atributos Export
export var escala_zoom:float = 4.0
export var tiempo_visible:float = 5.0

## Atributos
var escala_grilla:Vector2
var player:Player = null
var esta_visible:bool =true setget set_esta_visible

## Atributos Onready
onready var zona_renderizado:TextureRect = $CuadroMiniMapa/ContenedorIconos/ZonaRenderMiniMapa
onready var icono_base = $CuadroMiniMapa/ContenedorIconos/ZonaRenderMiniMapa/IconoBaseEnemiga
onready var icono_player:Sprite  = $CuadroMiniMapa/ContenedorIconos/ZonaRenderMiniMapa/IconoPlayer
onready var icono_estacion:Sprite = $CuadroMiniMapa/ContenedorIconos/ZonaRenderMiniMapa/IconoEstacion
onready var items_mini_mapa:Dictionary = {}
onready var icono_rele:Sprite = $CuadroMiniMapa/ContenedorIconos/ZonaRenderMiniMapa/IconoRele
onready var icono_interceptor:Sprite = $CuadroMiniMapa/ContenedorIconos/ZonaRenderMiniMapa/IconoInterceptor
onready var timer_visibilidad = $TimerVisibilidad
onready var tween_visibilidad:Tween = $TweenVisibilidad

## Setter y Getters
func set_esta_visible(hacer_visible: bool) -> void:
	if hacer_visible:
		timer_visibilidad.start()
	esta_visible = hacer_visible
	print ("Visible: ", esta_visible)
	if esta_visible:
		print ("Lo haremos visible")
	else:
		print ("Lo haremos invisible")

	tween_visibilidad.interpolate_property(
		self,
		"modulate",
		Color(1, 1, 1, not hacer_visible),
		Color(1, 1, 1, hacer_visible),
		0.5,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN_OUT
	)
	print (self.modulate)

## Metodos
func _ready() -> void:
	set_process(false)
	icono_player.position = zona_renderizado.rect_size * 0.5
	escala_grilla = zona_renderizado.rect_size / (get_viewport_rect().size * escala_zoom)
	conectar_seniales()

func _process(delta: float) -> void:
	if not player:
		return
	icono_player.rotation_degrees = player.rotation_degrees + 90
	modificar_posicion_iconos()

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("minimapa"):
		set_esta_visible(not esta_visible)

## Metodos Custom
func conectar_seniales() -> void:
	Eventos.connect("nivel_iniciado", self, "_on_nivel_iniciado")
	Eventos.connect("nave_destruida", self, "_on_nave_destruida")
	Eventos.connect("minimapa_objeto_creado", self, "obtener_objetos_minimapa")
	Eventos.connect("minimapa_objeto_destruido", self, "quitar_icono")

func _on_nivel_iniciado() -> void:
	player = DatosJuego.get_player_actual()
	obtener_objetos_minimapa()
	set_process(true)

func _on_nave_destruida(nave: NaveBase, _posicion, explosiones) -> void:
	if nave is Player:
		player = null

func obtener_objetos_minimapa() -> void:
	var objetivos_en_ventana:Array = get_tree().get_nodes_in_group("minimapa")
	for objeto in objetivos_en_ventana:
		if not items_mini_mapa.has(objeto):
			var sprite_icono:Sprite
			if objeto is BaseEnemiga:
				sprite_icono = icono_base.duplicate()
			elif objeto is EstacioRecarga:
				sprite_icono = icono_estacion.duplicate()
			elif objeto is EnemigoInterceptor:
				sprite_icono = icono_interceptor.duplicate()
			elif objeto is ReleDeMasa:
				sprite_icono = icono_rele

			items_mini_mapa[objeto] = sprite_icono
			items_mini_mapa[objeto].visible = true
			zona_renderizado.add_child(items_mini_mapa[objeto])

func modificar_posicion_iconos() -> void:
	for item in items_mini_mapa:
		var item_icono:Sprite = items_mini_mapa[item]
		var offset_pos:Vector2 = item.position - player.position
		var pos_icono:Vector2 = offset_pos * escala_grilla + (zona_renderizado.rect_size * 0.5)
		pos_icono.x = clamp(pos_icono.x, 0, zona_renderizado.rect_size.x)
		pos_icono.y = clamp(pos_icono.y, 0, zona_renderizado.rect_size.y)
		item_icono.position = pos_icono
		if zona_renderizado.get_rect().has_point(pos_icono - zona_renderizado.rect_position):
			item_icono.scale = Vector2(0.5, 0.5)
		else:
			item_icono.scale = Vector2(0.3, 0.3)

func quitar_icono(objeto: Node2D) -> void:
	if objeto in items_mini_mapa:
		items_mini_mapa[objeto].queue_free()
		items_mini_mapa.erase(objeto)

## Señales internas
func _on_TimerVisibilidad_timeout() -> void:
	if esta_visible:
		set_esta_visible(false)
