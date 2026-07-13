class_name Gema
extends Node2D

# =====================================================
#  GEMA DE EXPERIENCIA — la sueltan los enemigos al morir.
#  El farero la atrae cuando se acerca (radio imán).
# =====================================================
var xp := 1
var tiempo := randf() * 10.0

func _process(delta):
    tiempo += delta
    queue_redraw()

func _draw():
    var t := 1.0 + 0.2 * sin(tiempo * 6.0)
    var puntos := PackedVector2Array([
        Vector2(0, -7 * t), Vector2(5 * t, 0),
        Vector2(0, 7 * t), Vector2(-5 * t, 0),
    ])
    draw_colored_polygon(puntos, Color(0.3, 0.95, 0.9))
    draw_circle(Vector2.ZERO, 2.0, Color(0.9, 1, 1))
