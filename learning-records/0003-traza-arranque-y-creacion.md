# Traza el arranque y localiza la creación de actores

El estudiante recuperó sin apoyo la cadena `F5 → project.godot → main.tscn → main.gd → actores → frames` e identificó que la aparición de enemigos debe investigarse primero en `main.gd`, porque el director decide crearlos. Esto corrige la confusión previa entre crear un actor y ejecutar su comportamiento interno.

**Evidence:** reformuló correctamente ambas respuestas después de recibir una pista conceptual.

**Implications:** ya puede descender una capa y estudiar el ciclo de vida de `main.gd`: inicialización única frente a actualización por frame.
