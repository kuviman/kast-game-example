use (import "./la.ks").*;

module:

const Vertex = newtype {
    .a_pos :: Vec3,
};

const Face = newtype {
    .a :: Vertex,
    .b :: Vertex,
    .c :: Vertex,
};

const strip_prefix = (s :: String, prefix :: String) -> Option.t[String] => (
    if prefix |> String.length > s |> String.length then (
        :None
    ) else if (s |> String.substring(0, String.length(prefix)) == prefix) then (
        :Some (s |> String.substring(String.length(prefix), String.length(s) - String.length(prefix)))
    ) else (
        :None
    )
);

const parse = (s :: String) -> List.t[Face] => (
    let mut result = List.create();
    let mut vs = List.create();
    let vertex = (s :: String) -> Vertex => (
        # let v, vt_vn = s |> String.split_once('/');
        let v :: Int32 = String.parse(s);
        List.at(&vs, v - 1)^
    );
    for line in s |> String.lines do (
        if line |> strip_prefix("v ") is :Some (s) then (
            dbg.print(s);
            let { x, yz } = s |> String.split_once(' ');
            let { y, z } = yz |> String.split_once(' ');
            let x = x |> String.parse;
            let y = y |> String.parse;
            let z = z |> String.parse;
            let vertex :: Vertex = {
                .a_pos = { x, y, z },
            };
            &mut vs |> List.push_back(vertex);
        ) else if line |> strip_prefix("f ") is :Some (s) then (
            dbg.print(s);
            let { a, bc } = s |> String.split_once(' ');
            let { b, c } = bc |> String.split_once(' ');
            let face :: Face = {
                .a = vertex(a),
                .b = vertex(b),
                .c = vertex(c),
            };
            List.push_back(&mut result, face);
        );
    );
    result
);
