precision mediump float;

varying vec2 v_pos;

void main() {
    gl_FragColor = vec4(v_pos, 0.0, 1.0);
}