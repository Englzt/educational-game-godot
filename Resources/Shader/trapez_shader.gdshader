shader_type canvas_item;

uniform vec2 p1 = vec2(0.0, 0.0);
uniform vec2 p2 = vec2(1.0, 0.0);
uniform vec2 p3 = vec2(1.0, 1.0);
uniform vec2 p4 = vec2(0.0, 1.0);

uniform vec2 size = vec2(100.0, 100.0); // <- Manuell gesetzte Größe

void vertex() {
	vec2 corners[4] = vec2[4](p1, p2, p3, p4);
	VERTEX = mix(
		mix(corners[0], corners[1], UV.x),
		mix(corners[3], corners[2], UV.x),
		UV.y
	) * size;
}
