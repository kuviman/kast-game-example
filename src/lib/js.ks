module:

const Any = @opaque_type;

const unsafe_cast = [T, U] (a :: T) -> U => (
    (@native "x=>x")(a)
);
