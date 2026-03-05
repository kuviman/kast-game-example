module:

const Path = String;

const join_path = (a :: Path, b :: Path) -> Path => (
    a + "/" + b
);

const Load = [Self] newtype {
    .load :: Path -> Self,
};

const derive_Load = (ty :: Type) -> std.Ast => @cfg (
    | target.name == "interpreter" => match std.reflection.type_info(ty) with (
        | :Tuple { .unnamed, .named } => (
            match unnamed with (
                | :Nil => ()
                | :Cons _ => panic("Expected zero unnamed fields")
            );
            let mut load_fields = `();
            let path = `(path);
            for &{ name, field_ty } in std.collections.SList.iter(&named) do (
                let name_ident = std.Ast.ident(name);
                load_fields = `(
                    $load_fields,
                    .$name_ident = (
                        let field_path = join_path($path, name);
                        (field_ty as Load).load(field_path)
                    )
                );
            );
            `(
                impl ty as Load = {
                    .load = $path => {
                        $load_fields
                    },
                };
            )
        )
        | _ => panic("Can't derive Load")
    )
    | true => panic("Only usable at comptime")
);