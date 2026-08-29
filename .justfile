default:
    echo "Hi"

build-c:
    kastc compile \
        --target c \
        --output target/compiled/main.c \
        src/main.ks

build-native:
    ${CC:-gcc} \
        -lgc -lSDL3 -lSDL3_image -lGL -lGLEW \
        -Wfatal-errors \
        -fsanitize=address,leak,undefined \
        -g -O1 \
        -o target/compiled/main.exe \
        target/compiled/main.c
    # -fno-omit-frame-pointer \

build-emscripten:
    rm -rf target/web
    mkdir -p target/web
    LDFLAGS="-sBINARYEN_EXTRA_PASSES='--spill-pointers'" \
        emcc \
        target/compiled/main.c \
        -o target/web/index.html \
        -I ${BOEHMGC_WEB}/include \
        -L ${BOEHMGC_WEB}/lib \
        -lgc \
        -I ${SDL3_WEB}/include \
        -L ${SDL3_WEB}/lib \
        -l SDL3 \
        -I ${SDL3_IMAGE_WEB}/include \
        -L ${SDL3_IMAGE_WEB}/lib \
        -Os \
        --use-preload-plugins \
        --preload-file assets \
        -s TOTAL_STACK=64MB \
        -s INITIAL_MEMORY=128MB \
        -s ASSERTIONS \
        -w
    # --shell-file shell.html \
    # -sMAX_WEBGL_VERSION=2 \
    # -s ASYNCIFY \

run:
    just build-c
    just build-native
    LSAN_OPTIONS='suppresions=suppr.txt' \
        ./target/compiled/main.exe

serve:
    just build-c
    just build-emscripten
    caddy run
