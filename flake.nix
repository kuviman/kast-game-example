{
  description = "A devShell example";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nixpkgs-25-11.url = "github:NixOS/nixpkgs/nixos-25.11";
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
        pkgs-25-11 = import inputs.nixpkgs-25-11 { inherit system; };
        kast = inputs.kast.packages.${system}.default;
        kast-selfhost = pkgs.writeShellApplication {
          name = "kast";
          runtimeInputs = [ pkgs.nodejs ];
          text = ''
            node ${inputs.kast-selfhost.packages.${system}.kast-js}/kast.mjs "$@"
          '';
        };
        clang = pkgs.clang_22;
        sdl3-web = with pkgs-25-11;
          stdenv.mkDerivation {
            name = "sdl3-web";
            src = fetchFromGitHub {
              owner = "libsdl-org";
              repo = "SDL";
              rev = "release-3.4.14";
              hash = "sha256-HzV5Fq+PhJr/dQBCVm2WL1BdaI4GG+W+B0scttjdRuQ=";
            };
            buildInputs = [
              emscripten
              cmake
            ];
            dontUseCmakeConfigure = true;
            buildPhase = ''
              emcmake cmake .
              emmake make
            '';
            installPhase = ''
              cmake --install . --prefix $out
            '';
          };
        boehmgc-web = with pkgs-25-11;
          stdenv.mkDerivation {
            name = "boehmgc-web";
            src = fetchFromGitHub {
              owner = "bdwgc";
              repo = "bdwgc";
              rev = "331e007fffa19b6344982b7eb3f4ea8f973f68c7";
              hash = "sha256-dlcXJNDSMXlbeQqUd5deghJuS3dXrn3MQENpI8BE/ZE=";
            };
            buildInputs = [
              emscripten
              automake
              autoconf
              libtool
            ];
            buildPhase = ''
              ./autogen.sh
              export EM_CACHE="$(pwd)/.cache/emscripten"
              # LDFLAGS="-sBINARYEN_EXTRA_PASSES='--spill-pointers'"
              emconfigure ./configure
              emmake make
            '';
            installPhase = ''
              emmake make DESTDIR=$(pwd)/dest install
              cp -r dest/usr/local $out
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
            boehmgc-web
            libGL
            glew
            clang
            valgrind
            emscripten
          ];
          # Since I dont have cmake or whatever
          CLANGD_FLAGS = "--query-driver=${clang}/bin/clang*";
          KAST_PATH = "./kast_path";
          BOEHMGC_WEB = "${boehmgc-web}";
          SDL3_WEB = "${sdl3-web}";
          SDL3_IMAGE_WEB = "${pkgs.lib.getOutput "dev" pkgs.sdl3-image}";
        };
      });
}
