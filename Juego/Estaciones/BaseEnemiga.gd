#BaseEnemiga.gd
class_name BaseEnemiga
extends Node2D

## Atributos Export
export var hitpoints:float = 100.0
export var enemigo_orbital:PackedScene = null
export var numero_orbitales:int = 10
export var intervalo_spawn:float = 0.8
export (Array, PackedScene) var rutas

## Atributos Onready
onready var impacto_sfx:AudioStreamPlayer2D = $ImpactosSFX
onready var timer_spawner:Timer = $TimerSpawnerEnemigos
onready var barra_salud = $BarraSalud

## Atributos
var esta_destruida:bool = false
var posicion_spawn:Vector2 = Vector2.ZERO
var ruta_seleccionada:Path2D

## Metodos
func _ready() -> void:
	barra_salud.set_valores(hitpoints)
	
	timer_spawner.wait_time = intervalo_spawn
	$AnimationPlayer.play(elegir_animacion_aleatoria())
	seleccionar_ruta()

func _process(delta: float) -> void:
	var player_objetivo:Player = DatosJuego.get_player_actual()
	if not player_objetivo or player_objetivo == null:
		return
	var dir_player:Vector2 = player_objetivo.global_position - global_position
	var angulo_player:float = rad2deg(dir_player.angle())

## Metodos Custom
func elegir_animacion_aleatoria() -> String:
	randomize()
	var num_anim:int = $AnimationPlayer.get_animation_list().size() - 1
	var indice_anim_aleatoria:int = randi() % num_anim + 1
	var lista_animacion:Array = $AnimationPlayer.get_animation_list()
	return lista_animacion[indice_anim_aleatoria]

func recibir_danio(danio:float) -> void:
	hitpoints -= danio
	if hitpoints <= 0 and not esta_destruida:
		esta_destruida  = true
		destruir_me()
	impacto_sfx.play()
	barra_salud.set_hitpoints_actual(hitpoints)

func destruir_me() -> void:
	var posiciones = [
		$Sprites/SpaceStation017.global_position,
		$Sprites/SpaceStation024.global_position,
		$Sprites/SpaceStation028.global_position,
		$Sprites/SpaceStation029.global_position
	]
	Eventos.emit_signal("base_destruida", self, posiciones )
	Eventos.emit_signal("minimapa_objeto_destruido", self)
	queue_free()

func spawnear_orbital() -> void:
	numero_orbitales -= 1
	ruta_seleccionada.global_position = global_position
	
	var new_orbital: EnemigoOrbital= enemigo_orbital.instance()
	new_orbital.crear(
		global_position + posicion_spawn,
		self,
		ruta_seleccionada
	)
	Eventos.emit_signal("spawn_orbital", new_orbital)

func deteccion_cuadrante() -> Vector2:
	var player_objetivo:Player = DatosJuego.get_player_actual()
	
	if not player_objetivo:
		return Vector2.ZERO
	
	var dir_player:Vector2 = player_objetivo.global_position - global_position
	var angulo_player:float = rad2deg(dir_player.angle())
	
	if abs(angulo_player) <= 45.0:
		#Player entra por la derecha
		ruta_seleccionada.rotation_degrees = 180.0
		return $PosicionesSpawn/Este.position
	elif abs(angulo_player) > 135.0 and abs(angulo_player) <= 180.0:
		#Player entra por la izquierda
		ruta_seleccionada.rotation_degrees = 0.0
		return $PosicionesSpawn/Oeste.position
	elif abs(angulo_player) > 45.0 and abs(angulo_player) <= 135.0:
		if sign(angulo_player) >0:
			#Player entra por abajo
			ruta_seleccionada.rotation_degrees = 270.0
			return $PosicionesSpawn/Sur.position
		else:
			#Player entra por arriba
			ruta_seleccionada.rotation_degrees = 90.0
			return $PosicionesSpawn/Norte.position
	
	return $PosicionesSpawn/Norte.position

func seleccionar_ruta() -> void:
	randomize()
	var indice_ruta:int = randi() % rutas.size() - 1
	ruta_seleccionada = rutas[indice_ruta].instance()
	add_child(ruta_seleccionada)

## Se??ales Internas
func _on_AreaColision_body_entered(body: Node) -> void:
	if body.has_method("destruir"):
		body.destruir()

func _on_VisibilityNotifier2D_screen_entered() -> void:
	#spawn orbital
	$VisibilityNotifier2D.queue_free()
	posicion_spawn = deteccion_cuadrante()
	spawnear_orbital()
	timer_spawner.start()

func _on_TimerSpawnerEnemigos_timeout() -> void:
	if numero_orbitales == 0:
		timer_spawner.stop()
		return
	spawnear_orbital()
