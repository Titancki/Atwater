shader_type canvas_item;

uniform float speed = 0.05;
uniform float strength = 5.0;
uniform float scale = 20.0;

void fragment() {
    vec2 uv = UV;

    // Wave distortion
    float wave = sin(uv.y * scale + TIME * speed) * 0.01;
    uv.x += wave * strength;

    float wave2 = cos(uv.x * scale * 0.7 + TIME * speed * 1.3) * 0.01;
    uv.y += wave2 * strength;

    vec4 color = texture(TEXTURE, uv);

    // Optional: slight shimmer
    float shimmer = sin(TIME + uv.x * 10.0) * 0.05;
    color.rgb += shimmer;

    COLOR = color;
}