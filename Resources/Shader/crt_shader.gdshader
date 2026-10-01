shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform float scanline_count : hint_range(0.0, 1800.0) = 50.0;
uniform float scanline_speed = 1.0;

vec2 uv_curve(vec2 uv) {
    uv = (uv - 0.5) * 2.0;
    uv.x *= 1.0 + pow(abs(uv.y) / 3.0, 2.0);
    uv.y *= 1.0 + pow(abs(uv.x) / 3.0, 2.0);
    uv /= 1.2;
    uv = uv * 0.5 + 0.5;
    return uv;
}

void fragment() {
    //vec2 curved_uv = uv_curve(SCREEN_UV);
	vec2 curved_uv = SCREEN_UV;

    vec2 pixel_size = 1.0 / vec2(textureSize(screen_texture, 0));

    float r = textureLod(screen_texture, curved_uv + vec2(pixel_size.x * 0.0, 0.0), 0.0).r;
    float g = textureLod(screen_texture, curved_uv + vec2(pixel_size.x * 3.0, 0.0), 0.0).g;
    float b = textureLod(screen_texture, curved_uv + vec2(pixel_size.x * -3.0, 0.0), 0.0).b;

    float s = sin(curved_uv.y * scanline_count * PI * 2.0 + TIME * scanline_speed);
    s = (s * 0.5 + 0.5) * 0.9 + 0.1;
    vec4 scan_line = vec4(vec3(pow(s, 0.25)), 1.0);

    COLOR *= vec4(r, g, b, 1.0) * scan_line;
}
