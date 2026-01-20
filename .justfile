default:
    echo "Hi"

build:
    kast compile \
        --target js \
        --output target/compiled/main.mjs \
        src/main.ks

serve:
    just build
    caddy file-server \
        --listen 127.0.0.1:8080 \
        --root target
