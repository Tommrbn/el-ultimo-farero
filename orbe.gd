class_name Orbe
extends Node2D

# =====================================================
#  ORBE DE LUZ — el proyectil del farol.
#  Sale solo hacia el enemigo más cercano (ver main.gd).
# =====================================================
var direccion := Vector2.RIGHT
var rapidez := 480.0
var danio := 6.0
var perforaciones := 0        # enemigos extra que puede atravesar
var vida_util := 1.7          # segundos antes de apagarse
var golpeados: Array = []     # para no dañar dos veces al mismo enemigo

func _process(delta):
    position += direccion * rapidez * delta
    vida_util -= delta
    if vida_util <= 0.0:
        queue_free()
    queue_redraw()

func _draw():
    draw_circle(Vector2.ZERO, 10.0, Color(1.0, 0.95, 0.6, 0.25))
    draw_circle(Vector2.ZERO, 6.0, Color(1.0, 0.9, 0.4, 0.7))
    draw_circle(Vector2.ZERO, 3.0, Color(1, 1, 1))
