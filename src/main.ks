use std.collections.Map;
include "lib/_lib.ks";

let (.geng = geng_ctx, .gl = gl_ctx) = geng.init();
with geng.Context = geng_ctx;
with gl.Context = gl_ctx;

let grass_program = (
    let vertex_shader = ugli.compile_shader(
        gl.VERTEX_SHADER,
        fetch_string("shaders/grass/vertex.glsl")
    );
    let fragment_shader = ugli.compile_shader(
        gl.FRAGMENT_SHADER,
        fetch_string("shaders/grass/fragment.glsl")
    );
    ugli.Program.init(vertex_shader, fragment_shader)
);

const PLAYER_OFFSET = 2;
const BACKGROUND_COLOR = (0, 0, 0.1, 1);
const ENEMY_SPAWN_TIME = 1;
const ENEMY_SPEED = 0.3;
const ENEMY_SPAWN_DISTANCE = (.min = 3, .max = 7);
const PLAYER_SPEED = 3;
const PLAYER_MAX_VERTICAL_SPEED = 5;
const JUMP_SPEED = 10;
const PLAYER_ACCEL = 20;
const PLAYER_RADIUS = 0.3;
const ENEMY_RADIUS = 0.3;
const FOV = 5;
const GRAVITY = 10;

const GROUND = 0;
const MAX_HEIGHT = 3;

let textures = (
    .player = ugli.Texture.init(load_image("unicorn.png"), :Nearest),
    .enemy = ugli.Texture.init(load_image("angry.png"), :Nearest),
    .grass = (
        let mut texture = ugli.Texture.init(load_image("grass.png"), :Nearest);
        &mut texture |> ugli.Texture.set_wrap_separate(:Repeat, :ClampToEdge);
        texture
    ),
);

const Unit = newtype (
    .pos :: Vec2,
    .half_size :: Vec2,
    .vel :: Vec2,
    .texture :: ugli.Texture,
    .on_ground :: Bool,
);

impl Unit as module = (
    module:
    
    const update = (unit :: &mut Unit, dt :: Float64) => (
        unit^.pos = Vec2.add(unit^.pos, Vec2.mul(unit^.vel, dt));
    );
    
    const draw = (unit :: &Unit) => (
        geng.draw_quad(
            .pos = unit^.pos,
            .half_size = unit^.half_size,
            .texture = unit^.texture,
        );
    );
);

let check_collision = (a :: &Unit, b :: &Unit) -> Bool => (
    abs(a^.pos.0 - b^.pos.0) < a^.half_size.0 + b^.half_size.0
    and abs(a^.pos.1 - b^.pos.1) < a^.half_size.1 + b^.half_size.1
);

let mut player :: Option.t[Unit] = :Some(
    .pos = (0, 0),
    .half_size = (PLAYER_RADIUS, PLAYER_RADIUS),
    .vel = (0, 0),
    .texture = textures.player,
    .on_ground = false,
);

let mut camera :: geng.Camera = (
    .pos = (0, (GROUND + MAX_HEIGHT) / 2),
    .fov = FOV,
);

use std.collections.Treap;

let mut enemies = Treap.create();
let spawn_enemy = () => (
    let x = camera.pos.0 + FOV;
    let y = std.random.gen_range(
        .min = -FOV / 2,
        .max = +FOV / 2,
    );
    let enemy = (
        .pos = (x, y),
        .half_size = (ENEMY_RADIUS, ENEMY_RADIUS),
        .vel = (0, 0),
        .texture = textures.enemy,
        .on_ground = true,
    );
    enemies = Treap.join(enemies, Treap.singleton(enemy));
);

let start_time = time.now();
let mut t = time.now();
let mut next_enemy = camera.pos.0;

let draw_grass = () => (
    let camera = (@current geng.CameraCtx);
    let geng = (@current geng.Context);
    let program = grass_program;
    program |> ugli.Program.@"use";
    
    let mut draw_state = ugli.DrawState.init();
    let draw_state = &mut draw_state;
    
    program |> ugli.set_uniform("u_ground", GROUND, draw_state);
    program |> ugli.set_uniform("u_view_matrix", camera.view_matrix, draw_state);
    program |> ugli.set_uniform("u_projection_matrix", camera.projection_matrix, draw_state);
    program |> ugli.set_uniform("u_texture", textures.grass, draw_state);
    program |> ugli.set_uniform("u_texture_size_in_world_coords", Vec2.mul((32, 8), 2 * 0.3 / 16), draw_state);
    program |> ugli.set_vertex_data_source(geng.quad.buffer);
    gl.draw_arrays(gl.TRIANGLE_FAN, 0, 4);
);

loop (
    let framebuffer_size = (
        geng_ctx.canvas_size.width,
        geng_ctx.canvas_size.height,
    );
    let dt = (
        let new_t = time.now();
        let dt = new_t - t;
        t = new_t;
        dt
    );
    while camera.pos.0 > next_enemy do (
        spawn_enemy();
        next_enemy = camera.pos.0 + std.random.gen_range(ENEMY_SPAWN_DISTANCE);
    );
    while Treap.length(&enemies) != 0 do (
        let first = Treap.at(&enemies, 0);
        if first^.pos.0 < camera.pos.0 - FOV then (
            _, enemies = Treap.split_at(enemies, 1);
        ) else break;
    );
    if player is :Some(ref mut player) then (
        player^.vel.0 = min(player^.vel.0 + PLAYER_ACCEL * dt, PLAYER_SPEED);
        let up = (
            input.is_key_pressed(:Space)
            or input.is_key_pressed(:ArrowUp)
        );
        player^.vel.1 = clamp(
            player^.vel.1 + (if up then +1 else -1) * PLAYER_ACCEL * dt,
            .min = -PLAYER_MAX_VERTICAL_SPEED,
            .max = +PLAYER_MAX_VERTICAL_SPEED,
        );
        if up and player^.on_ground then (
            player^.vel.1 = JUMP_SPEED;
        );
        player |> Unit.update(dt);
        if player^.pos.1 < GROUND + player^.half_size.1 then (
            player^.vel.1 = 0;
            player^.pos.1 = GROUND + player^.half_size.1;
            player^.on_ground = true;
        ) else (
            player^.on_ground = false;
        );
        if player^.pos.1 > MAX_HEIGHT - player^.half_size.1 then (
            player^.vel.1 = 0;
            player^.pos.1 = MAX_HEIGHT - player^.half_size.1;
        );
        let half_screen = 0.5 * FOV * framebuffer_size.0 / framebuffer_size.1;
        camera.pos.0 = (
            player^.pos.0
            + half_screen
            - min(PLAYER_OFFSET, half_screen)
        );
    );
    for enemy in Treap.iter_mut(&mut enemies) do (
        enemy |> Unit.update(dt);
        if player is :Some(ref player_unit) then (
            if check_collision(&enemy^, player_unit) then (
                player = :None;
            );
        );
    );
    
    with geng.CameraCtx = geng.CameraUniforms.init(
        camera,
        .framebuffer_size,
    );
    
    ugli.clear(BACKGROUND_COLOR);
    draw_grass();
    
    let aspect = geng_ctx.canvas_size.width / geng_ctx.canvas_size.height;
    
    for enemy in Treap.iter(&enemies) do (
        enemy |> Unit.draw;
    );
    if player is :Some(ref player) then (
        player |> Unit.draw;
    );
    
    geng.await_next_frame();
);
