const Float32 = Float64;

const Vec2 = newtype (Float32, Float32);

impl Vec2 as module = (
    module:
    const add = ((ax, ay) :: Vec2, (bx, by) :: Vec2) -> Vec2 => (
        ax + bx, ay + by
    );
    const sub = ((ax, ay) :: Vec2, (bx, by) :: Vec2) -> Vec2 => (
        ax - bx, ay - by
    );
    const mul = ((x, y) :: Vec2, k :: Float32) -> Vec2 => (
        x * k, y * k
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
