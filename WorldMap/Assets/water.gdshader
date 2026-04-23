shader_type canvas_item;

uniform float speed = 1.5;
uniform float ripple_offset = 0.0;

uniform float ripple_width = 0.08;
uniform float ripple_freq = 40.0;

// NEW
uniform float max_distance = 0.8; // 80% of the foam area

void fragment() {
    vec2 uv = UV;

    float mask = texture(TEXTURE, uv).r;

    // --- LIMIT DISTANCE ---
    float dist = mask * max_distance;

    // normalize so 0 → max_distance maps to 0 → 1
    float limited = dist / max_distance;

    // kill everything beyond the limit
    float cutoff = step(dist, max_distance);

    // --- RIPPLE ---
    float wave = sin(limited * ripple_freq + TIME * speed + ripple_offset);

    float foam = smoothstep(1.0 - ripple_width, 1.0, wave);

    foam *= dist;     // only outside land
    foam *= cutoff;   // remove outer 20%

    // --- SOFT FADE (important for nice edge) ---
    float fade = smoothstep(max_distance, max_distance - 0.1, dist);
    foam *= fade;

    // --- OUTPUT ---
    vec3 foam_color = vec3(0.9, 0.95, 1.0);

    COLOR.rgb = foam_color * foam;
    COLOR.a = foam;
}