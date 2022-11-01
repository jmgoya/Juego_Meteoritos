extends EnemigosBase

## Atributos Export
export var rango_max_ataque: float = 800.0

func rotar_hacia_player() -> void:
	.rotar_hacia_player()
	if dir_player.length() > rango_max_ataque:
		canion.set_esta_disparando(false)
	else:
		canion.set_esta_disparando(true)
