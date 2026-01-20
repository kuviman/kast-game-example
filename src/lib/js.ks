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

const List = @opaque_type;

impl List as module = (
    module:
    
    const init = () -> List => (
        @native "[]"
    );
    const push = [T] (list :: List, x :: T) -> () => (
        (@native "({list,x})=>list.push(x)")(.list, .x)
    );
);
