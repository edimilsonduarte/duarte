#!/usr/bin/env bash
# Diagnóstico geral do VPS — só leitura, não altera nada.
set -u

echo "=== Data do servidor ==="
date

echo
echo "=== Versão do PHP em cada aplicação ==="
for c in dudusaas_app dudusaas_app_homolog freteja_app; do
  echo "--- $c ---"
  docker exec "$c" php -v 2>&1 | head -2 || echo "(container não encontrado ou sem PHP)"
done

echo
echo "=== Containers em execução ==="
docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}'

echo
echo "=== Espaço em disco ==="
df -h / | tail -1

echo
echo "=== Dependências do TubeClean (dudusaas_app) ==="
docker exec dudusaas_app yt-dlp --version 2>&1 || echo "yt-dlp: NÃO instalado"
docker exec dudusaas_app deno --version 2>&1 | head -1 || echo "deno: NÃO instalado"
docker exec dudusaas_app ffmpeg -version 2>&1 | head -1 || echo "ffmpeg: NÃO instalado"
docker exec dudusaas_app ls -l /etc/yt-dlp.conf /etc/yt-dlp-cookies.txt 2>&1 || echo "config/cookies do yt-dlp: ausentes"
