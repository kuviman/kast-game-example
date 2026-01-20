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

const compile_shader = (shader_type, source) => (
    let shader = ctx
        |> GL.create_shader(shader_type)
        |> Option.unwrap;
    ctx |> GL.shader_source(shader, source);
    ctx |> GL.compile_shader(shader);
    let compile_status = ctx
        |> GL.get_shader_parameter_bool(
            shader, gl.COMPILE_STATUS
        );
    if not compile_status then (
        let log = ctx
            |> GL.get_shader_info_log(shader);
        panic("Shader compilation failed: " + log);
    );
    shader
);

let vertex_shader = compile_shader(
    gl.VERTEX_SHADER,
    VERTEX_SHADER_SOURCE,
);
let fragment_shader = compile_shader(
    gl.FRAGMENT_SHADER,
    FRAGMENT_SHADER_SOURCE,
);

let program = ctx
    |> GL.create_program
    |> Option.unwrap;
ctx |> GL.attach_shader(program, vertex_shader);
ctx |> GL.attach_shader(program, fragment_shader);
ctx |> GL.link_program(program);
let link_status = ctx |> GL.get_program_parameter_bool(program, gl.LINK_STATUS);
if not link_status then (
    let log = ctx
        |> GL.get_program_info_log(program);
    panic("Program link failed: " + log);
);

dbg.print(.program);
