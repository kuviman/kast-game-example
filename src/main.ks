use std.collections.Map;
include "lib/_lib.ks";

let (.geng = geng_ctx, .gl = gl_ctx) = geng.init();
with geng.Context = geng_ctx;
with gl.Context = gl_ctx;

const BACKGROUND_COLOR = (0.8, 0.8, 1.0, 1.0);
const ENEMY_SPAWN_TIME = 1;
const ENEMY_SPEED = 0.3;
const PLAYER_SPEED = 3;
const PLAYER_RADIUS = 0.3;
const ENEMY_RADIUS = 0.3;

let textures = (
    .player = ugli.Texture.init(load_image("player.png"), :Nearest),
    .enemy = ugli.Texture.init(load_image("enemy.png"), :Nearest)
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
        geng.draw_quad(
            .pos = unit^.pos,
            .radius = unit^.radius,
            .projection_matrix,
            .texture = unit^.texture,
        );
    );
);

let check_collision = (a :: &Unit, b :: &Unit) -> Bool => (
    abs(a^.pos.0 - b^.pos.0) < a^.radius + b^.radius
    and abs(a^.pos.1 - b^.pos.1) < a^.radius + b^.radius
);

let mut player :: Option.t[Unit] = :Some(
    .pos = (0, 0),
    .radius = PLAYER_RADIUS,
    .vel = (0, 0),
    .texture = textures.player,
);

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
    
    ugli.clear(BACKGROUND_COLOR);
    
    let aspect = geng_ctx.canvas_size.width / geng_ctx.canvas_size.height;
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
    
    geng.await_next_frame();
);
