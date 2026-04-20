shader_type spatial;

render_mode unshaded, cull_disabled, depth_draw_opaque, blend_mix;

uniform float ground_y = 0.0;
uniform float opacity : hint_range(0.0, 1.0) = 0.4;
uniform vec3 shadow_offset = vec3(0.0, 0.0, 0.0);

void vertex() {
    vec3 world_pos = (MODEL_MATRIX * vec4(-VERTEX, 1.0)).xyz;

    world_pos += shadow_offset;

    vec3 cam_dir = normalize(world_pos - CAMERA_POSITION_WORLD);

    float t = (world_pos.y - ground_y) / cam_dir.y;
    world_pos += cam_dir * t;

    world_pos.y = ground_y + 0.01;

    VERTEX = (INV_VIEW_MATRIX * vec4(world_pos, 1.0)).xyz;
}

void fragment() {
    ALBEDO = vec3(0.0);
    ALPHA = opacity;
}