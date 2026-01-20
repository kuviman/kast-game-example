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

const teapot_src = std.fs.read_file(
    std.path.dirname(__FILE__) + "/test.obj"
);
let faces = obj.parse(teapot_src);
let mut data = List.create();
for face in List.iter(&faces) do (
    &mut data |> List.push_back(face^.a);
    &mut data |> List.push_back(face^.b);
    &mut data |> List.push_back(face^.c);
);

program |> ugli.Program.@"use";
ugli.bind_field(program, &data, "a_pos", vertex => vertex^.a_pos);
ctx |> GL.draw_arrays(gl.TRIANGLES, 0, List.length(&data));
