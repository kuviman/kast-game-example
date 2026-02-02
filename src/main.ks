use std.collections.Map;
use (import "lib/_lib.ks").*;

# geng.init :: () with (Allocator, Async) -> () with (geng.Context, gl.Context);
let { .geng = geng_ctx, .gl = gl_ctx } = geng.init();

with geng.Context = geng_ctx;
with gl.Context = gl_ctx;
with input.Context = input.init(geng_ctx.canvas);
with audio.Context = audio.init();

let assets = (
    module:
    
    let music = audio.load("assets/music.wav");
    audio.play_with(
        music,
        {
            .@"loop" = true,
            .gain = 2,
        },
    );
    let sfx = {
        .jump = audio.load("assets/sfx/jump.wav"),
        .hit = audio.load("assets/sfx/hit.wav"),
        .pickup_star = audio.load("assets/sfx/pickup_star.wav"),
    };
    let font = font.Font.load("assets/font");
    
    let shaders = {
        .background = geng.load_shader("assets/shaders/background"),
    };
    
    let load_texture = path => geng.load_texture("assets/textures/" + path, :Nearest);
    
    let load_background_texture = path => (
        let mut texture = load_texture(path);
        &mut texture |> ugli.Texture.set_wrap_separate(:Repeat, :ClampToEdge);
        texture
    );
    
    let textures = {
        .player = load_texture("unicorn.png"),
        .enemy = load_texture("angry.png"),
        .grass = load_background_texture("grass.png"),
        .clouds = load_background_texture("clouds.png"),
        .play = load_texture("play.png"),
        .star = load_texture("star.png"),
        .fullscreen = load_texture("fullscreen.png"),
        .mute = load_texture("mute.png"),
        .muted = load_texture("muted.png"),
    };
);

const PLAYER_OFFSET = 2;
const BACKGROUND_COLOR = { 0, 0, 0.1, 1 };
const ENEMY_SPAWN_TIME = 1;
const ENEMY_SPEED = 0.3;
const SPAWN_DISTANCE = { .min = 3, .max = 7 };
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

const Entity = newtype {
    .pos :: Vec2,
    .half_size :: Vec2,
    .vel :: Vec2,
    .texture :: ugli.Texture,
    .on_ground :: Bool,
};

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

const QuadPos = newtype {
    .pos :: Vec2,
    .half_size :: Vec2,
};

const ZERO_QUAD_POS :: QuadPos = {
    .pos = { 0, 0 },
    .half_size = { 0, 0 },
};

let mut muted = false;

const State = newtype {
    .player :: Option.t[Entity],
    .enemies :: Treap.t[Entity],
    .stars :: Treap.t[Entity],
    .camera :: geng.Camera,
    .next_spawn :: Float32,
    .score :: Int32,
    .play_button_pos :: QuadPos,
    .fullscreen_button_pos :: QuadPos,
    .mute_button_pos :: QuadPos,
};

# const StateCtx = @context State;
impl State as module = (
    module:
    
    const init = () -> State => {
        .player = :None,
        .enemies = Treap.create(),
        .camera = {
            .pos = { 0, (GROUND + MAX_HEIGHT) / 2 },
            .fov = FOV,
        },
        .stars = Treap.create(),
        .next_spawn = 0,
        .score = 0,
        .play_button_pos = ZERO_QUAD_POS,
        .fullscreen_button_pos = ZERO_QUAD_POS,
        .mute_button_pos = ZERO_QUAD_POS,
    };
    
    const restart = (state :: &mut State) => (
        state^ = {
            ...State.init(),
            .player = :Some {
                .pos = { 0, 0 },
                .half_size = { PLAYER_RADIUS, PLAYER_RADIUS },
                .vel = { 0, 0 },
                .texture = assets.textures.player,
                .on_ground = false,
            },
        };
    );
    
    const spawn = (state :: &mut State) => (
        let x = state^.camera.pos.0 + FOV;
        let y = std.random.gen_range(
            .min = GROUND + ENEMY_RADIUS,
            .max = MAX_HEIGHT - ENEMY_RADIUS,
        );
        let is_enemy = std.random.gen_range[Float32](.min = 0, .max = 1) < STAR_CHANCE;
        let texture = if is_enemy then (
            assets.textures.enemy
        ) else (
            assets.textures.star
        );
        let entity = {
            .pos = { x, y },
            .half_size = { ENEMY_RADIUS, ENEMY_RADIUS },
            .vel = { 0, 0 },
            .texture,
            .on_ground = true,
        };
        let collection = if is_enemy then (
            &mut state^.enemies
        ) else (
            &mut state^.stars
        );
        collection^ = Treap.join(collection^, Treap.singleton(entity));
    );
    
    const WhatIsClicked = newtype (
        | :Play
        | :Fullscreen
        | :Mute
    );
    
    const what_is_clicked = (
        state :: &State,
        screen_pos :: Vec2,
    ) -> Option.t[WhatIsClicked] => with_return (
        if state^.player is :Some (_) then return :None;
        let framebuffer_size = {
            geng_ctx.canvas_size.width,
            geng_ctx.canvas_size.height,
        };
        let pos = geng.Camera.screen_to_world(
            state^.camera,
            screen_pos,
            .framebuffer_size,
        );
        # dbg.print(.screen_pos, .pos);
        let check = (where :: QuadPos, what :: WhatIsClicked) => (
            if (
                pos.0 >= where.pos.0 - where.half_size.0
                and pos.1 >= where.pos.1 - where.half_size.1
                and pos.0 <= where.pos.0 + where.half_size.0
                and pos.1 <= where.pos.1 + where.half_size.1
            ) then (
                return :Some (what);
            )
        );
        check(state^.play_button_pos, :Play);
        check(state^.fullscreen_button_pos, :Fullscreen);
        check(state^.mute_button_pos, :Mute);
        :None
    );
    
    const handle_event = (state :: &mut State, event :: input.Event) => (
        match event with (
            | :PointerPress { .pos } => (
                match what_is_clicked(&state^, pos) with (
                    | :Some (:Play) => (
                        if state^.player is :None then (
                            state |> restart;
                        );
                    )
                    | :Some (:Fullscreen) => (
                        geng.toggle_fullscreen();
                    )
                    | :Some (:Mute) => (
                        muted = not muted;
                        audio.set_master_volume(if muted then 0 else 1);
                    )
                    | :None => ()
                );
            )
            | _ => ()
        );
    );
    
    const update = (state :: &mut State, dt :: Float32) => (
        let framebuffer_size = {
            geng_ctx.canvas_size.width,
            geng_ctx.canvas_size.height,
        };
        while state^.camera.pos.0 > state^.next_spawn do (
            state |> spawn;
            state^.next_spawn = (
                state^.camera.pos.0
                + std.random.gen_range(...SPAWN_DISTANCE)
            );
        );
        let despawn = collection => (
            while Treap.length(&collection^) != 0 do (
                let first = Treap.at(&collection^, 0);
                if first^.pos.0 < state^.camera.pos.0 - FOV then (
                    { _, collection^ } = Treap.split_at(collection^, 1);
                ) else break;
            );
        );
        despawn(&mut state^.enemies);
        despawn(&mut state^.stars);
        if state^.player is :Some (ref mut player) then (
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
                audio.play(assets.sfx.jump);
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
            for { i, entity } in Treap.iter_mut(collection) |> std.iter.enumerate do (
                entity |> Entity.update(dt);
                if state^.player is :Some (ref player_entity) then (
                    if check_collision(&entity^, player_entity) then (
                        match entity_type with (
                            | :Enemy => (
                                state^.player = :None;
                                audio.play(assets.sfx.hit);
                            )
                            | :Star => (
                                List.push_back(&mut to_despawn, i);
                                audio.play(assets.sfx.pickup_star);
                                state^.score += 1;
                            )
                        );
                    );
                );
            );
            const pop_back = [T] (a :: &mut List.t[T]) -> Option.t[T] => (
                let length = Treap.length(&a^.inner);
                if length == 0 then :None else (
                    { a^.inner, (let node) } = Treap.split_at(a^.inner, Treap.length(&a^.inner) - 1);
                    let :Node (data) = node;
                    :Some (data.value)
                )
            );
            
            loop (
                if pop_back(&mut to_despawn) is :Some (i) then (
                    let { before, i_and_after } = Treap.split_at(collection^, i);
                    let { _, after } = Treap.split_at(i_and_after, 1);
                    collection^ = Treap.join(before, after);
                ) else break;
            );
        );
        update_collection(&mut state^.enemies, :Enemy);
        update_collection(&mut state^.stars, :Star);
    );
    
    const draw = (state :: &mut State) => (
        let framebuffer_size = {
            geng_ctx.canvas_size.width,
            geng_ctx.canvas_size.height,
        };
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
        if state^.player is :Some (ref entity) then (
            entity |> Entity.draw;
        ) else (
            state^.play_button_pos = {
                .pos = { state^.camera.pos.0, 2 },
                .half_size = Vec2.div(assets.textures.play.size, 32),
            };
            geng.draw_quad(
                ...state^.play_button_pos,
                .texture = assets.textures.play,
            );
            
            state^.fullscreen_button_pos = {
                .pos = { state^.camera.pos.0, 0.8 },
                .half_size = Vec2.div(assets.textures.fullscreen.size, 64),
            };
            geng.draw_quad(
                ...state^.fullscreen_button_pos,
                .texture = assets.textures.fullscreen,
            );
            
            state^.mute_button_pos = {
                .pos = { state^.camera.pos.0, 0.4 },
                .half_size = Vec2.div(assets.textures.mute.size, 64),
            };
            geng.draw_quad(
                ...state^.mute_button_pos,
                .texture = if muted then (
                    assets.textures.muted
                ) else (
                    assets.textures.mute
                ),
            );
        );
        
        draw_score(&state^);
    );
    
    const draw_score = (state :: &State) => (
        let pos = {
            state^.camera.pos.0 + 0.4,
            -0.7,
        };
        &assets.font
            |> font.Font.draw(
                "score:",
                .pos,
                .size = 0.3,
                .color = { 1, 1, 1, 1 },
                .align = 1
            );
        &assets.font
            |> font.Font.draw(
                state^.score |> to_string,
                .pos,
                .size = 0.3,
                .color = { 1, 1, 1, 1 },
                .align = 0
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
        let program = assets.shaders.background;
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
            .texture = assets.textures.grass,
            .texture_offset = 0.7,
        );
    );
    
    const draw_clouds = () => (
        draw_background(
            .level = MAX_HEIGHT,
            .top = true,
            .texture = assets.textures.clouds,
            .texture_offset = 0.25,
        );
    );
);

let mut t = time.now();

let mut state = State.init();

loop (
    let framebuffer_size = {
        geng_ctx.canvas_size.width,
        geng_ctx.canvas_size.height,
    };
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
    State.draw(&mut state);
    
    geng.await_next_frame();
);
