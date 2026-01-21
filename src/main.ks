use std.collections.Map;
include "lib/_lib.ks";

const ENEMY_SPAWN_TIME = 1;
const ENEMY_SPEED = 0.3;
const PLAYER_SPEED = 3;
const PLAYER_RADIUS = 0.3;
const ENEMY_RADIUS = 0.3;

const time = (
    module:
    
    const now = () -> Float64 => (
        (@native "performance.now()") / 1000
    );
);

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

let program = (
    let vertex_shader = ctx
        |> ugli.compile_shader(
            gl.VERTEX_SHADER,
            fetch_string("vertex.glsl")
        );
    let fragment_shader = ctx
        |> ugli.compile_shader(
            gl.FRAGMENT_SHADER,
            fetch_string("fragment.glsl")
        );
    ctx |> ugli.Program.init(vertex_shader, fragment_shader)
);

const Vertex = newtype (
    .a_pos :: Vec2,
    .a_uv :: Vec2,
);

impl Vertex as ugli.Vertex = (
    .init_fields = (ctx, data, f) => (
        f("a_pos", ugli.VertexBuffer.init_field(ctx, data, v => v^.a_pos));
        f("a_uv", ugli.VertexBuffer.init_field(ctx, data, v => v^.a_uv));
    ),
);

let quad :: ugli.VertexBuffer.t[Vertex] = (
    let mut data :: List.t[Vertex] = List.create();
    List.push_back(
        &mut data,
        (
            .a_pos = (-1, -1),
            .a_uv = (0, 0),
        ),
    );
    List.push_back(
        &mut data,
        (
            .a_pos = (+1, -1),
            .a_uv = (1, 0),
        ),
    );
    List.push_back(
        &mut data,
        (
            .a_pos = (+1, +1),
            .a_uv = (1, 1),
        ),
    );
    List.push_back(
        &mut data,
        (
            .a_pos = (-1, +1),
            .a_uv = (0, 1),
        ),
    );
    ugli.VertexBuffer.init(ctx, &data)
);

const get_canvas_size = (canvas) -> (Float32, Float32) => (
    (@native "Runtime.get_canvas_size")(canvas)
);

let textures = (
    .player = ugli.Texture.init(ctx, load_image("player.png"), :Nearest),
    .enemy = ugli.Texture.init(ctx, load_image("enemy.png"), :Nearest)
);

let mut projection_matrix :: Mat3 = (
    (1, 0, 0),
    (0, 1, 0),
    (0, 0, 1),
);

let fov = 10;

const Unit = newtype (
    .pos :: Vec2,
    .radius :: Float32,
    .vel :: Vec2,
    .texture :: ugli.Texture,
);

impl Unit as module = (
    module:
    
    const update = (unit :: &mut Unit, dt :: Float64) => (
        unit^.pos = Vec2.add(unit^.pos, Vec2.mul(unit^.vel, dt));
    );
    
    const draw = (unit :: &Unit) => (
        program |> ugli.Program.@"use";
        
        let mut draw_state = ugli.DrawState.init();
        let draw_state = &mut draw_state;
        
        program |> ugli.set_uniform("u_pos", unit^.pos, draw_state);
        program |> ugli.set_uniform("u_radius", unit^.radius, draw_state);
        program |> ugli.set_uniform("u_projection_matrix", projection_matrix, draw_state);
        program |> ugli.set_uniform("u_texture", unit^.texture, draw_state);
        # TODO only upload data to GPU once
        quad |> ugli.VertexBuffer.@"use"(program);
        ctx |> GL.draw_arrays(gl.TRIANGLE_FAN, 0, 4);
    );
);

const abs = (x :: Float32) -> Float32 => (
    if x < 0 then (
        -x
    ) else (
        x
    )
);

let check_collision = (a :: &Unit, b :: &Unit) -> Bool => (
    abs(a^.pos.0 - b^.pos.0) < a^.radius + b^.radius
    and abs(a^.pos.1 - b^.pos.1) < a^.radius + b^.radius
);

let mut player :: Option.t[Unit] = :Some(.pos = (0, 0),
.radius = PLAYER_RADIUS,
.vel = (0, 0),
.texture = textures.player,);

use std.collections.Treap;

let mut enemies = Treap.create();
let spawn_enemy = () => (
    let edge = fov / 2;
    let start_pos = (std.random.gen_range(.min = -edge, .max = +edge), -edge);
    let end_pos = (std.random.gen_range(.min = -edge, .max = +edge), +edge);
    let enemy = (
        .pos = start_pos,
        .radius = ENEMY_RADIUS,
        .vel = Vec2.mul(Vec2.sub(end_pos, start_pos), ENEMY_SPEED),
        .texture = textures.enemy,
    );
    enemies = Treap.join(enemies, Treap.singleton(enemy));
);

let start_time = time.now();
let mut t = time.now();
let mut next_enemy = ENEMY_SPAWN_TIME;

loop (
    let dt = (
        let new_t = time.now();
        let dt = new_t - t;
        t = new_t;
        dt
    );
    next_enemy -= dt;
    while next_enemy < 0 do (
        spawn_enemy();
        next_enemy += ENEMY_SPAWN_TIME;
    );
    while Treap.length(&enemies) != 0 do (
        let first = Treap.at(&enemies, 0);
        if first^.pos.1 > fov then (
            _, enemies = Treap.split_at(enemies, 1);
        ) else break;
    );
    if player is :Some(ref mut player) then (
        player^.vel = (0, 0);
        if input.is_key_pressed(:ArrowLeft) then (
            player^.vel.0 -= 1;
        );
        if input.is_key_pressed(:ArrowRight) then (
            player^.vel.0 += 1;
        );
        if input.is_key_pressed(:ArrowUp) then (
            player^.vel.1 += 1;
        );
        if input.is_key_pressed(:ArrowDown) then (
            player^.vel.1 -= 1;
        );
        player^.vel = Vec2.mul(player^.vel, PLAYER_SPEED);
        player |> Unit.update(dt);
    );
    for enemy in Treap.iter_mut(&mut enemies) do (
        enemy |> Unit.update(dt);
        if player is :Some(ref player_unit) then (
            if check_collision(&enemy^, player_unit) then (
                player = :None;
            );
        );
    );
    
    ctx |> GL.clear_color(0.8, 0.8, 1.0, 1.0);
    ctx |> GL.clear(gl.COLOR_BUFFER_BIT);
    
    let (width, height) = canvas |> get_canvas_size;
    let aspect = width / height;
    projection_matrix = (
        (2 / aspect / fov, 0, 0),
        (0, 2 / fov, 0),
        (0, 0, 1),
    );
    
    for enemy in Treap.iter(&enemies) do (
        enemy |> Unit.draw;
    );
    if player is :Some(ref player) then (
        player |> Unit.draw;
    );
    
    await_animation_frame();
);
