shader_type canvas_item;

uniform bool enabled;
uniform vec4 color_on = vec4(0.0, 0.8, 0.4, 1.0);
uniform vec4 color_off = vec4(0.8, 0.0, 0.2, 1.0);

void fragment() {
	if(enabled) {
		COLOR *= color_on;
	} else {
		COLOR *= color_off;
	}
}
