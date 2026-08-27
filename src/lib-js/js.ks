use (import "./la.ks").*;

module:

const Any = @opaque_type;

const unsafe_cast = [T, U] (x :: T) -> U => (
    @native "\(x)"
);

const from_any = [T] (x :: Any) -> T => (
    @native "\(x)"
);

const into_any = [T] (x :: T) -> Any => (
    @native "\(x)"
);

const is_null = (x :: Any) -> Bool => (
    @native "\(x) === null"
);

const check_null = [T] (a :: Any) -> Option.t[T] => (
    if a |> is_null then (
        :None
    ) else (
        :Some (a |> from_any)
    )
);

const List = (
    module:
    
    const t = [T] @opaque_type;
    
    const init = [T] () -> t[T] => (
        @native "[]"
    );
    const push = [T] (list :: t[T], x :: T) -> () => (
        @native "\(list).push(\(x))"
    );
    const iter = [T] (list :: t[T]) -> std.iter.Iterable[T] => {
        .iter = f => (
            (@native "async(ctx,{list,f})=>{for(const x of list){await f(ctx,x)}}")(
                .list,
                .f,
            );
        ),
    };
);

const Obj = (
    module:
    
    const t = [T] @opaque_type;
    
    const iter = [T] (obj :: t[T]) -> std.iter.Iterable[type { String, T }] => {
        .iter = f => (
            (@native "async(ctx,{obj,f})=>{for(const [key,value]of Object.entries(obj)){await f(ctx,{0:key,1:value})}}")(
                .obj,
                .f,
            );
        ),
    };
);

const json_parse = [T] (json :: String) -> T => (
    @native "JSON.parse(\(json))"
);

const new_float32_array = (data :: List.t[Float32]) -> Any => (
    (@native "(ctx,data)=>new Float32Array(data)")(data)
)
