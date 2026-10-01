shader_type canvas_item;

uniform float max_shift = 2.5;
uniform float speed = 0.03;
uniform float frequency = 32.0; // controls the wave frequency

float random(vec2 pos) {
	return fract(sin(dot(pos, vec2(12.9898, 78.233))) * 43758.5453);
}

float noise(vec2 pos) {
	return random(floor(pos));
}

float value_noise(vec2 pos) {
	vec2 p = floor(pos);
	vec2 f = fract(pos);

	float v00 = noise(p + vec2(0.0, 0.0));
	float v10 = noise(p + vec2(1.0, 0.0));
	float v01 = noise(p + vec2(0.0, 1.0));
	float v11 = noise(p + vec2(1.0, 1.0));

	vec2 u = f * f * (3.0 - 2.0 * f);

	return mix(mix(v00, v10, u.x), mix(v01, v11, u.x), u.y);
}

void fragment() {
	vec2 uv_r = UV + vec2(TIME * speed, 0.0);
	vec2 uv_g = UV + vec2(-10.0, -TIME * speed);

	uv_r *= frequency;
	uv_g *= frequency;

	vec2 shift = vec2(
		sin(
			value_noise(uv_r) * 0.2 +
			value_noise(uv_r * 2.0) * 0.2 +
			value_noise(uv_r * 4.0) * 0.2 +
			value_noise(uv_r * 8.0) * 0.2 +
			value_noise(uv_r * 16.0) * 0.2
		) - 0.5,
		sin(
			value_noise(uv_g) * 0.2 +
			value_noise(uv_g * 2.0) * 0.2 +
			value_noise(uv_g * 4.0) * 0.2 +
			value_noise(uv_g * 8.0) * 0.2 +
			value_noise(uv_g * 16.0) * 0.2
		) - 0.5
	) * max_shift;

	COLOR = texture(TEXTURE, UV + shift);
}
