use std.collections.Map;
include "lib/_lib.ks";

let document = web.document();
let canvas :: web.HtmlCanvasElement = document
    |> web.HtmlDocumentElement.get_element_by_id("canvas")
    |> js.unsafe_cast;

const GL = gl.Context;

let ctx :: GL = canvas
    |> web.HtmlCanvasElement.get_context("webgl")
    |> js.unsafe_cast
    |> GL.init;

ctx |> GL.clear_color(0.8, 0.8, 1.0, 1.0);
ctx |> GL.clear(gl.COLOR_BUFFER_BIT);

const VERTEX_SHADER_SOURCE = std.fs.read_file(
    std.path.dirname(__FILE__) + "/vertex.glsl"
);
const FRAGMENT_SHADER_SOURCE = std.fs.read_file(
    std.path.dirname(__FILE__) + "/fragment.glsl"
);

let program = (
    let vertex_shader = ctx
        |> ugli.compile_shader(
            gl.VERTEX_SHADER,
            VERTEX_SHADER_SOURCE
        );
    let fragment_shader = ctx
        |> ugli.compile_shader(
            gl.FRAGMENT_SHADER,
            FRAGMENT_SHADER_SOURCE
        );
    ctx |> ugli.Program.init(vertex_shader, fragment_shader)
);

const Vertex = newtype (
    .a_pos :: Vec2,
    .a_color :: Vec4,
);

let mut data :: List.t[Vertex] = List.create();
List.push_back(
    &mut data,
    (
        .a_pos = (-1, -1),
        .a_color = (1, 0, 0, 1),
    )
);
List.push_back(
    &mut data,
    (
        .a_pos = (+1, -1),
        .a_color = (0, 1, 0, 1),
    )
);
List.push_back(
    &mut data,
    (
        .a_pos = (0, +1),
        .a_color = (0, 0, 1, 1),
    )
);

program |> ugli.Program.@"use";
ugli.bind_field(program, &data, "a_pos", vertex => vertex^.a_pos);
ugli.bind_field(program, &data, "a_color", vertex => vertex^.a_color);
ctx |> GL.draw_arrays(gl.TRIANGLES, 0, 3);
