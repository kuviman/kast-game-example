module:

const GL = gl.Context;

const SizedType = [Self] newtype (
    .size :: Int32,
);

impl Float32 as SizedType = (
    .size = 4,
);

const compile_shader = (ctx, shader_type, source) => (
    let shader = ctx
        |> GL.create_shader(shader_type)
        |> Option.unwrap;
    ctx |> GL.shader_source(shader, source);
    ctx |> GL.compile_shader(shader);
    let compile_status = ctx
        |> GL.get_shader_parameter_bool(
            shader, gl.COMPILE_STATUS
        );
    if not compile_status then (
        let log = ctx
            |> GL.get_shader_info_log(shader);
        panic("Shader compilation failed: " + log);
    );
    shader
);

const ActiveInfo = newtype (
    .raw :: gl.ActiveInfo,
    .index :: Int32,
);

const Program = newtype (
    .ctx :: gl.Context,
    .handle :: gl.Program,
    .attributes :: Map.t[String, ActiveInfo],
);

impl Program as module = (
    module:
    
    const init = (
        ctx,
        vertex_shader :: gl.Shader,
        fragment_shader :: gl.Shader,
    ) -> Program => (
        let program = ctx
            |> GL.create_program
            |> Option.unwrap;
        ctx |> GL.attach_shader(program, vertex_shader);
        ctx |> GL.attach_shader(program, fragment_shader);
        ctx |> GL.link_program(program);
        let link_status = ctx |> GL.get_program_parameter_bool(program, gl.LINK_STATUS);
        if not link_status then (
            let log = ctx
                |> GL.get_program_info_log(program);
            panic("Program link failed: " + log);
        );
        let active_attributes = ctx
            |> GL.get_program_parameter_int(program, gl.ACTIVE_ATTRIBUTES);
        let mut attributes = Map.create();
        for index in 0..active_attributes do (
            let active_info = ctx
                |> GL.get_active_attrib(program, index);
            if active_info.size != 1 then (
                dbg.print(active_info);
                panic("active_info.size != 1");
            );
            let active_info = (
                .raw = active_info,
                .index,
            );
            Map.add(&mut attributes, active_info.raw.name, active_info);
        );
        (
            .ctx,
            .handle = program,
            .attributes,
        )
    );
    
    const @"use" = (program :: Program) => (
        program.ctx |> GL.use_program(program.handle);
    );
);

const VertexAttribute = [Self] newtype (
    .size :: gl.GLint,
    .@"type" :: gl.GLenum,
    .type_size :: Int32,
    .construct_data :: &List.t[Self] -> js.Any,
);

impl Vec2 as VertexAttribute = (
    .size = 2,
    .@"type" = gl.FLOAT,
    .type_size = 4,
    .construct_data = data => (
        let list = js.List.init();
        for &(x, y) in List.iter(data) do (
            list |> js.List.push(x);
            list |> js.List.push(y);
        );
        (@native "list=>new Float32Array(list)")(list)
    ),
);

impl Vec4 as VertexAttribute = (
    .size = 4,
    .@"type" = gl.FLOAT,
    .type_size = 4,
    .construct_data = data => (
        let list = js.List.init();
        for &(x, y, z, w) in List.iter(data) do (
            list |> js.List.push(x);
            list |> js.List.push(y);
            list |> js.List.push(z);
            list |> js.List.push(w);
        );
        (@native "list=>new Float32Array(list)")(list)
    ),
);

const bind_field = [V, T] (
    program :: Program,
    data :: &List.t[V],
    name :: String,
    get :: &V -> T,
) => with_return (
    let ctx = program.ctx;
    let active_info = match &program.attributes |> Map.get(name) with (
        | :Some(info) => info
        | :None => return
    );
    
    let mut field_data = List.create();
    for vertex in List.iter(data) do (
        let field = get(vertex);
        &mut field_data |> List.push_back(field);
    );
    let field_data = (T as VertexAttribute).construct_data(&field_data);
    
    let buffer = ctx |> GL.create_buffer;
    ctx |> GL.bind_buffer(gl.ARRAY_BUFFER, buffer);
    ctx |> GL.buffer_data(gl.ARRAY_BUFFER, field_data, gl.STATIC_DRAW);
    
    dbg.print(field_data);
    
    let offset = 0;
    let stride = (
        (T as VertexAttribute).size
        * (T as VertexAttribute).type_size
    );
    GL.vertex_attrib_pointer(
        ctx,
        active_info^.index,
        (T as VertexAttribute).size,
        (T as VertexAttribute).@"type",
        false,
        stride,
        offset,
    );
    ctx |> GL.enable_vertex_attrib_array(active_info^.index);
);
