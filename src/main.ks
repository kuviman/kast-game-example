use std.collections.Map;
include "lib/_lib.ks";

const load_image = (url :: String) -> web.HtmlImageElement => (
    (@native "Runtime.load_image")(url)
);

let document = web.document();
let canvas :: web.HtmlCanvasElement = document
    |> web.HtmlDocumentElement.get_element_by_id("canvas")
    |> js.unsafe_cast;

const await_animation_frame = () -> () => (
    (@native "window.Runtime.await_animation_frame")()
);

const GL = gl.Context;

let ctx :: GL = (
    let webgl :: web.WebGLRenderingContext = canvas
        |> web.HtmlCanvasElement.get_context("webgl")
        |> js.unsafe_cast;
    
    const setup_canvas_size = (canvas :: web.HtmlCanvasElement) -> () => (
        (@native "window.Runtime.setup_canvas_size")(
            .canvas,
            .webgl
        )
    );
    canvas |> setup_canvas_size;
    
    webgl
        |> GL.init
);

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
);

let quad = (
    let mut data :: List.t[Vertex] = List.create();
    List.push_back(
        &mut data,
        (
            .a_pos = (0, 0),
        ),
    );
    List.push_back(
        &mut data,
        (
            .a_pos = (1, 0),
        ),
    );
    List.push_back(
        &mut data,
        (
            .a_pos = (1, 1),
        ),
    );
    List.push_back(
        &mut data,
        (
            .a_pos = (0, 1),
        ),
    );
    data
);

const get_canvas_size = (canvas) -> (Float32, Float32) => (
    (@native "Runtime.get_canvas_size")(canvas)
);

let image = load_image("image.png");
let texture = ugli.Texture.init(ctx, image);

let fov = 10;

let mut pos :: Vec2 = (0, 0);
let mut vel :: Vec2 = (1, 0);

loop (
    let dt = 0.01;
    pos.0 += vel.0 * dt;
    pos.1 += vel.1 * dt;
    if pos.0 > 1 then (
        pos.0 = 1;
        vel.0 = -vel.0;
    );
    if pos.0 < -1 then (
        pos.0 = -1;
        vel.0 = -vel.0;
    );
    
    ctx |> GL.clear_color(0.8, 0.8, 1.0, 1.0);
    ctx |> GL.clear(gl.COLOR_BUFFER_BIT);
    
    let (width, height) = canvas |> get_canvas_size;
    let aspect = width / height;
    let projection_matrix :: Mat3 = (
        (2 / aspect / fov, 0, 0),
        (0, 2 / fov, 0),
        (0, 0, 1),
    );
    
    program |> ugli.Program.@"use";
    
    let mut draw_state = ugli.DrawState.init();
    let draw_state = &mut draw_state;
    
    program |> ugli.set_uniform("u_pos", pos, draw_state);
    program |> ugli.set_uniform("u_projection_matrix", projection_matrix, draw_state);
    program |> ugli.set_uniform("u_texture", texture, draw_state);
    # TODO only upload data to GPU once
    ugli.bind_field(program, &quad, "a_pos", vertex => vertex^.a_pos);
    ctx |> GL.draw_arrays(gl.TRIANGLE_FAN, 0, List.length(&quad));
    await_animation_frame();
);
