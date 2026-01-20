module:

const Any = @opaque_type;

const unsafe_cast = [T, U] (a :: T) -> U => (
    (@native "x=>x")(a)
);

const is_null = (x :: Any) -> Bool => (
    (@native "x=>(x===null)")(x)
);

const check_null = [T] (a :: Any) -> Option.t[T] => (
    if a |> is_null then (
        :None
    ) else (
        :Some(a |> unsafe_cast)
    )
);
