#!/usr/bin/env bash
# Reinstala as dependências do módulo TubeClean no container dudusaas_app.
# Necessário após qualquer recriação do container (até entrarem no Dockerfile).
set -euo pipefail

C=dudusaas_app

echo ">>> Instalando ffmpeg, unzip e curl"
docker exec -u 0 "$C" bash -c 'apt-get update -qq && apt-get install -y -qq ffmpeg unzip curl'

echo ">>> Instalando yt-dlp"
docker exec -u 0 "$C" bash -c 'curl -sL https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp_linux -o /usr/local/bin/yt-dlp && chmod a+rx /usr/local/bin/yt-dlp'

echo ">>> Instalando Deno (ambiente JS exigido pelo yt-dlp para YouTube)"
docker exec -u 0 "$C" bash -c 'curl -sL https://github.com/denoland/deno/releases/latest/download/deno-x86_64-unknown-linux-gnu.zip -o /tmp/deno.zip && unzip -oq /tmp/deno.zip -d /usr/local/bin && chmod +x /usr/local/bin/deno && rm /tmp/deno.zip'

echo ">>> Configurando cookies globais do yt-dlp"
docker exec -u 0 "$C" bash -c 'echo "--cookies /etc/yt-dlp-cookies.txt" > /etc/yt-dlp.conf'
if [ -f /root/cookies.txt ]; then
  docker cp /root/cookies.txt "$C":/etc/yt-dlp-cookies.txt
  echo "cookies copiados de /root/cookies.txt"
else
  echo "AVISO: /root/cookies.txt não existe no VPS — YouTube pode bloquear com verificação de robô"
fi

echo ">>> Verificação final"
docker exec "$C" yt-dlp --version
docker exec "$C" deno --version | head -1
docker exec "$C" ffmpeg -version | head -1
echo "OK: dependências do TubeClean prontas"
