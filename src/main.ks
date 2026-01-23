use std.collections.Map;
include "lib/_lib.ks";

let (.geng = geng_ctx, .gl = gl_ctx) = geng.init();
with geng.Context = geng_ctx;
with gl.Context = gl_ctx;
with input.Context = input.init();
with audio.Context = audio.init();
let music = audio.load("music.wav");
audio.play_with(
    music,
    (
        .@"loop" = true,
        .gain = 2,
    ),
);
let sfx = (
    .jump = audio.load("sfx/jump.wav"),
    .hit = audio.load("sfx/hit.wav"),
    .pickup_star = audio.load("sfx/pickup_star.wav"),
);

let load_shader = name => (
    let vertex_shader = ugli.compile_shader(
        gl.VERTEX_SHADER,
        fetch_string("shaders/" + name + "/vertex.glsl")
    );
    let fragment_shader = ugli.compile_shader(
        gl.FRAGMENT_SHADER,
        fetch_string("shaders/" + name + "/fragment.glsl")
    );
    ugli.Program.init(vertex_shader, fragment_shader)
);

let shaders = (
    .background = load_shader("background"),
);

let load_texture = path => ugli.Texture.init(load_image(path), :Nearest);

let load_background_texture = path => (
    let mut texture = load_texture(path);
    &mut texture |> ugli.Texture.set_wrap_separate(:Repeat, :ClampToEdge);
    texture
);

let textures = (
    .player = load_texture("unicorn.png"),
    .enemy = load_texture("angry.png"),
    .grass = load_background_texture("grass.png"),
    .clouds = load_background_texture("clouds.png"),
    .play = load_texture("play.png"),
    .star = load_texture("star.png"),
);

const PLAYER_OFFSET = 2;
const BACKGROUND_COLOR = (0, 0, 0.1, 1);
const ENEMY_SPAWN_TIME = 1;
const ENEMY_SPEED = 0.3;
const SPAWN_DISTANCE = (.min = 3, .max = 7);
const STAR_CHANCE = 0.5;
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

const Entity = newtype (
    .pos :: Vec2,
    .half_size :: Vec2,
    .vel :: Vec2,
    .texture :: ugli.Texture,
    .on_ground :: Bool,
);

impl Entity as module = (
    module:
    
    const update = (entity :: &mut Entity, dt :: Float64) => (
        entity^.pos = Vec2.add(entity^.pos, Vec2.mul(entity^.vel, dt));
    );
    
    const draw = (entity :: &Entity) => (
        geng.draw_quad(
            .pos = entity^.pos,
            .half_size = entity^.half_size,
            .texture = entity^.texture,
        );
    );
);

let check_collision = (a :: &Entity, b :: &Entity) -> Bool => (
    abs(a^.pos.0 - b^.pos.0) < a^.half_size.0 + b^.half_size.0
    and abs(a^.pos.1 - b^.pos.1) < a^.half_size.1 + b^.half_size.1
);

use std.collections.Treap;

const State = newtype (
    .player :: Option.t[Entity],
    .enemies :: Treap.t[Entity],
    .stars :: Treap.t[Entity],
    .camera :: geng.Camera,
    .next_spawn :: Float32,
);

# const StateCtx = @context State;
impl State as module = (
    module:
    
    const init = () -> State => (
        .player = :None,
        .enemies = Treap.create(),
        .camera = (
            .pos = (0, (GROUND + MAX_HEIGHT) / 2),
            .fov = FOV,
        ),
        .stars = Treap.create(),
        .next_spawn = 0,
    );
    
    const restart = (state :: &mut State) => (
        state^ = (
            ...State.init(),
            .player = :Some(
                .pos = (0, 0),
                .half_size = (PLAYER_RADIUS, PLAYER_RADIUS),
                .vel = (0, 0),
                .texture = textures.player,
                .on_ground = false,
            ),
        );
    );
    
    const spawn = (state :: &mut State) => (
        let x = state^.camera.pos.0 + FOV;
        let y = std.random.gen_range(
            .min = GROUND + ENEMY_RADIUS,
            .max = MAX_HEIGHT - ENEMY_RADIUS,
        );
        let is_enemy = std.random.gen_range[Float32](.min = 0, .max = 1) < STAR_CHANCE;
        let texture = if is_enemy then textures.enemy else textures.star;
        let entity = (
            .pos = (x, y),
            .half_size = (ENEMY_RADIUS, ENEMY_RADIUS),
            .vel = (0, 0),
            .texture,
            .on_ground = true,
        );
        let collection = if is_enemy then (
            &mut state^.enemies
        ) else (
            &mut state^.stars
        );
        collection^ = Treap.join(collection^, Treap.singleton(entity));
    );
    
    const handle_event = (state :: &mut State, event :: input.Event) => (
        match event with (
            | :MousePress(_) => (
                if state^.player is :None then (
                    state |> restart;
                );
            )
            | _ => ()
        );
    );
    
    const update = (state :: &mut State, dt :: Float32) => (
        let framebuffer_size = (
            geng_ctx.canvas_size.width,
            geng_ctx.canvas_size.height,
        );
        while state^.camera.pos.0 > state^.next_spawn do (
            state |> spawn;
            state^.next_spawn = (
                state^.camera.pos.0
                + std.random.gen_range(SPAWN_DISTANCE)
            );
        );
        let despawn = collection => (
            while Treap.length(&collection^) != 0 do (
                let first = Treap.at(&collection^, 0);
                if first^.pos.0 < state^.camera.pos.0 - FOV then (
                    _, collection^ = Treap.split_at(collection^, 1);
                ) else break;
            );
        );
        despawn(&mut state^.enemies);
        despawn(&mut state^.stars);
        if state^.player is :Some(ref mut player) then (
            player^.vel.0 = min(player^.vel.0 + PLAYER_ACCEL * dt, PLAYER_SPEED);
            let up = (
                input.Key.is_pressed(:Space)
                or input.Key.is_pressed(:ArrowUp)
                or input.is_any_pointer_pressed()
            );
            player^.vel.1 = clamp(
                player^.vel.1 + (if up then +1 else -1) * PLAYER_ACCEL * dt,
                .min = -PLAYER_MAX_VERTICAL_SPEED,
                .max = +PLAYER_MAX_VERTICAL_SPEED,
            );
            if up and player^.on_ground then (
                player^.vel.1 = JUMP_SPEED;
                audio.play(sfx.jump);
            );
            player |> Entity.update(dt);
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
            state^.camera.pos.0 = (
                player^.pos.0
                + half_screen
                - min(PLAYER_OFFSET, half_screen)
            );
        );
        let update_collection = (collection, entity_type) => (
            let mut to_despawn = List.create();
            for (i, entity) in Treap.iter_mut(collection) |> std.iter.enumerate do (
                entity |> Entity.update(dt);
                if state^.player is :Some(ref player_entity) then (
                    if check_collision(&entity^, player_entity) then (
                        match entity_type with (
                            | :Enemy => (
                                state^.player = :None;
                                audio.play(sfx.hit);
                            )
                            | :Star => (
                                List.push_back(&mut to_despawn, i);
                                audio.play(sfx.pickup_star);
                            )
                        );
                    );
                );
            );
            const pop_back = [T] (a :: &mut List.t[T]) -> Option.t[T] => (
                let length = Treap.length(&a^.inner);
                if length == 0 then :None else (
                    a^.inner, (let node) = Treap.split_at(a^.inner, Treap.length(&a^.inner) - 1);
                    let :Node(data) = node;
                    :Some(data.value)
                )
            );
            
            loop (
                if pop_back(&mut to_despawn) is :Some(i) then (
                    let before, i_and_after = Treap.split_at(collection^, i);
                    let _, after = Treap.split_at(i_and_after, 1);
                    collection^ = Treap.join(before, after);
                ) else break;
            );
        );
        update_collection(&mut state^.enemies, :Enemy);
        update_collection(&mut state^.stars, :Star);
    );
    
    const draw = (state :: &State) => (
        let framebuffer_size = (
            geng_ctx.canvas_size.width,
            geng_ctx.canvas_size.height,
        );
        with geng.CameraCtx = geng.CameraUniforms.init(
            state^.camera,
            .framebuffer_size,
        );
        
        ugli.clear(BACKGROUND_COLOR);
        draw_grass();
        draw_clouds();
        for entity in Treap.iter(&state^.enemies) do (
            entity |> Entity.draw;
        );
        for entity in Treap.iter(&state^.stars) do (
            entity |> Entity.draw;
        );
        if state^.player is :Some(ref entity) then (
            entity |> Entity.draw;
        ) else (
            geng.draw_quad(
                .pos = state^.camera.pos,
                .half_size = (1, 1),
                .texture = textures.play,
            );
        );
    );
    
    const draw_background = (
        .level :: Float32,
        .top :: Bool,
        .texture :: ugli.Texture,
        .texture_offset :: Float32,
    ) => (
        let camera = (@current geng.CameraCtx);
        let geng = (@current geng.Context);
        let program = shaders.background;
        program |> ugli.Program.@"use";
        
        let mut draw_state = ugli.DrawState.init();
        let draw_state = &mut draw_state;
        
        program |> ugli.set_uniform("u_level", level, draw_state);
        let top :: Float32 = if top then 1 else 0;
        program |> ugli.set_uniform("u_top", top, draw_state);
        program |> ugli.set_uniform("u_texture_offset", texture_offset, draw_state);
        program |> ugli.set_uniform("u_view_matrix", camera.view_matrix, draw_state);
        program |> ugli.set_uniform("u_projection_matrix", camera.projection_matrix, draw_state);
        program |> ugli.set_uniform("u_texture", texture, draw_state);
        program |> ugli.set_uniform("u_texture_size_in_world_coords", Vec2.mul(texture.size, 2 * 0.3 / 16), draw_state);
        program |> ugli.set_vertex_data_source(geng.quad.buffer);
        gl.draw_arrays(gl.TRIANGLE_FAN, 0, 4);
    );
    
    const draw_grass = () => (
        draw_background(
            .level = GROUND,
            .top = false,
            .texture = textures.grass,
            .texture_offset = 0.7,
        );
    );
    
    const draw_clouds = () => (
        draw_background(
            .level = MAX_HEIGHT,
            .top = true,
            .texture = textures.clouds,
            .texture_offset = 0.25,
        );
    );
);

let mut t = time.now();

let mut state = State.init();

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
    for event in input.iter_events() do (
        State.handle_event(&mut state, event);
    );
    State.update(&mut state, dt);
    State.draw(&state);
    
    geng.await_next_frame();
);
