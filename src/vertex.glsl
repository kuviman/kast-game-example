precision mediump float;

attribute vec2 a_pos;
attribute vec4 a_color;

varying vec4 v_color;
varying vec2 v_uv;

uniform mat3 u_projection_matrix;

void main() {
    v_uv = a_pos;
    v_color = a_color;
    vec3 screen_pos = u_projection_matrix * vec3(a_pos, 1.0);
    gl_Position = vec4(screen_pos.xy, 0.0, screen_pos.z);
}