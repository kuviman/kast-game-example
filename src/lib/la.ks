const Float32 = Float64;

const Vec2 = newtype (Float32, Float32);

impl Vec2 as module = (
    module:
    const add = (a :: Vec2, b :: Vec2) -> Vec2 => (
        a.0 + b.0, a.1 + b.1
    );
    const sub = (a :: Vec2, b :: Vec2) -> Vec2 => (
        a.0 - b.0, a.1 - b.1
    );
    const mul = (v :: Vec2, k :: Float32) -> Vec2 => (
        v.0 * k, v.1 * k
    );
    const vmul = (a :: Vec2, b :: Vec2) -> Vec2 => (
        a.0 * b.0, a.1 * b.1
    );
    const vdiv = (a :: Vec2, b :: Vec2) -> Vec2 => (
        a.0 / b.0, a.1 / b.1
    );
);

const Vec3 = newtype (Float32, Float32, Float32);
const Vec4 = newtype (Float32, Float32, Float32, Float32);

const Mat3 = newtype (Vec3, Vec3, Vec3);
# const Mat3 = @opaque_type;
# impl Mat3 as module = (
#     module:
#     const from_rows = (row0 :: Vec3, row1 :: Vec3, row2 :: Vec3) -> Mat3 => (
#     )
# )
