shader_type canvas_item;

uniform float amplitude       : hint_range(0.0, 20.0) = 5.0;
uniform float frequency       : hint_range(-10.0, 10.0) = 3.0;
uniform float speed           : hint_range(0.0, 5.0) = 1.0;
uniform int pole_side         = 0;
uniform float fixed_edge_range: hint_range(0.0, 1.0) = 0.2;

void fragment() {
    vec2 distorted_uv = UV;
    float wave;
    float influence;

    if (pole_side == 2 || pole_side == 3) {
        wave = sin(UV.x * frequency + TIME * speed) * amplitude * 0.01;
        if (pole_side == 2) {
            influence = 1.0 - smoothstep(1.0 - fixed_edge_range, 1.0, UV.x);
        } else {
            influence = smoothstep(0.0, fixed_edge_range, UV.x);
        }
        distorted_uv.y += wave * influence;
    } else {
        wave = sin(UV.y * frequency + TIME * speed) * amplitude * 0.01;
        if (pole_side == 0) {
            influence = smoothstep(0.0, fixed_edge_range, UV.y);
        } else {
            influence = 1.0 - smoothstep(1.0 - fixed_edge_range, 1.0, UV.y);
        }
        distorted_uv.x += wave * influence;
    }

    vec4 tex_color = texture(TEXTURE, distorted_uv);
    
    if (tex_color.r < 0.05 && tex_color.g < 0.05 && tex_color.b < 0.05) {
        tex_color.a = 0.0;
    }

    COLOR = tex_color;
}
