include "lib/_lib.ks";

let document = web.document();
let canvas :: web.HtmlCanvasElement = document
    |> web.HtmlDocumentElement.get_element_by_id("canvas")
    |> js.unsafe_cast;

let ctx :: gl.Context = canvas
    |> web.HtmlCanvasElement.get_context("webgl")
    |> js.unsafe_cast
    |> gl.Context.init;

ctx |> gl.Context.clear_color(0.8, 0.8, 1.0, 1.0);
ctx |> gl.Context.clear(gl.COLOR_BUFFER_BIT);

const VERTEX_SHADER_SOURCE = std.fs.read_file(
    std.path.dirname(__FILE__) + "/vertex.glsl"
);
const FRAGMENT_SHADER_SOURCE = std.fs.read_file(
    std.path.dirname(__FILE__) + "/fragment.glsl"
);

const compile_shader = (shader_type, source) => (
    let shader = ctx
        |> gl.Context.create_shader(shader_type)
        |> Option.unwrap;
    ctx |> gl.Context.shader_source(shader, source);
    ctx |> gl.Context.compile_shader(shader);
    let compile_status = ctx
        |> gl.Context.get_shader_parameter_bool(
            shader, gl.COMPILE_STATUS
        );
    if not compile_status then (
        let log = ctx
            |> gl.Context.get_shader_info_log(shader);
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

dbg.print(.vertex_shader, .fragment_shader);

print("Hello, world2");
