{
  description = "A devShell example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    kast.url = "github:kast-lang/kast/bootstrap-ocaml";
    kast-selfhost.url = "git+https://github.com/kast-lang/kast?rev=9cbd998cdb9adf1e3b25cf9599f1e26743f80016&submodules=1";
    # kast.url = "git+file:/home/kuviman/projects/kast-lang/kast";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = inputs:
    inputs.flake-utils.lib.eachDefaultSystem (system:
      let
        overlays = [ ];
        pkgs = import inputs.nixpkgs { inherit system overlays; };
        kast = inputs.kast.packages.${system}.default;
        kast-selfhost = pkgs.writeShellApplication {
          name = "kast";
          runtimeInputs = [ pkgs.nodejs ];
          text = ''
            node ${inputs.kast-selfhost.packages.${system}.kast-js}/kast.mjs "$@"
          '';
        };
        clang = pkgs.clang_22;
        boehmgc-web = pkgs.stdenv.mkDerivation {
          name = "raylib-web";
          src = pkgs.boehmgc.src;
          buildInputs = [ pkgs.emscripten pkgs.cmake ];
          buildPhase = ''
            emcmake cmake .
            cmake --build .
          '';
          installPhase = ''
            mkdir $out
            ls -la .
            cp libraylib.web.a $out/libraylib.web.a
          '';
        };
      in
      with pkgs; {
        packages = {
          inherit boehmgc-web;
        };
        devShells.default = mkShell {
          packages = [
            (pkgs.writeShellScriptBin "kastc" ''
              systemd-run --user --scope -p MemoryMax=10G \
                rlwrap ${kast}/bin/kast "$@"
            '')
            kast-selfhost
            rlwrap
            nixfmt
            nodejs
            just
            caddy
            inotify-tools
            sdl3
            sdl3-image
            boehmgc
            libGL
            glew
            clang
            valgrind
            emscripten
          ];
          # Since I dont have cmake or whatever
          CLANGD_FLAGS = "--query-driver=${clang}/bin/clang*";
          KAST_PATH = "./kast_path";
          BOEHMGC = "${pkgs.lib.getOutput "dev" pkgs.boehmgc}";
          SDL3 = "${pkgs.lib.getOutput "dev" pkgs.sdl3}";
          SDL3_IMAGE = "${pkgs.lib.getOutput "dev" pkgs.sdl3-image}";
        };
      });
}
