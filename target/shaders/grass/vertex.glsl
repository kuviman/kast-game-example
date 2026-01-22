precision mediump float;

attribute vec2 a_pos;

varying vec2 v_uv;

uniform mat3 u_view_matrix;
uniform mat3 u_projection_matrix;

uniform float u_ground;
uniform vec2 u_texture_size_in_world_coords;

mat3 inverse(mat3 m) {
  float a00 = m[0][0], a01 = m[0][1], a02 = m[0][2];
  float a10 = m[1][0], a11 = m[1][1], a12 = m[1][2];
  float a20 = m[2][0], a21 = m[2][1], a22 = m[2][2];

  float b01 = a22 * a11 - a12 * a21;
  float b11 = -a22 * a10 + a12 * a20;
  float b21 = a21 * a10 - a11 * a20;

  float det = a00 * b01 + a01 * b11 + a02 * b21;

  return mat3(b01, (-a22 * a01 + a02 * a21), (a12 * a01 - a02 * a11),
              b11, (a22 * a00 - a02 * a20), (-a12 * a00 + a02 * a10),
              b21, (-a21 * a00 + a01 * a20), (a11 * a00 - a01 * a10)) / det;
}

void main() {
    // mat * (-1, .., 1) = (-1, .., 1);
    // mat * (1, .., 1) = (1, .., 1);
    // mat * (.., -1, 1) = (.., -1, 1);
    // mat * (.., 1, 1) = (.., top, 1);
    float top = u_ground + u_texture_size_in_world_coords.y * 0.7;
    float top_screen_pos = (
        u_projection_matrix * u_view_matrix 
        * vec3(0.0, top, 1.0)
    ).y;
    float k = a_pos.y * 0.5 + 0.5;
    vec2 screen_pos = vec2(
        a_pos.x,
        top_screen_pos * k + (1.0 - k) * (-1.0));
    vec3 world_pos = inverse(u_projection_matrix * u_view_matrix)
        * vec3(screen_pos, 1.0);
    v_uv = vec2(world_pos.x, world_pos.y - top)
        / u_texture_size_in_world_coords
        + vec2(0.0, 1.0);
    gl_Position = vec4(screen_pos, 0.0, 1.0);
}