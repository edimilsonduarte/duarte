#!/usr/bin/env bash
# Atualiza o PHP dos containers de aplicação puxando/reconstruindo as imagens
# com a base php:8.2 mais recente (correções de segurança 8.2.35+).
# Ao final, reinstala as dependências do TubeClean (a reconstrução as apaga).
set -euo pipefail

atualiza_compose() {
  local container="$1" modo="$2"
  local dir
  dir=$(docker inspect "$container" --format '{{index .Config.Labels "com.docker.compose.project.working_dir"}}' 2>/dev/null || true)
  if [ -z "$dir" ]; then
    echo "AVISO: $container não foi criado via docker compose — atualize manualmente"
    return 0
  fi
  echo ">>> Atualizando $container (compose em $dir, modo $modo)"
  if [ "$modo" = "build" ]; then
    (cd "$dir" && docker compose build --pull && docker compose up -d)
  else
    (cd "$dir" && docker compose pull && docker compose up -d)
  fi
}

atualiza_compose freteja_app pull
atualiza_compose dudusaas_app build

echo ">>> Aguardando containers subirem"
sleep 10

echo ">>> Versões finais do PHP"
docker exec freteja_app php -v 2>&1 | head -1 || true
docker exec dudusaas_app php -v 2>&1 | head -1 || true

echo ">>> Reinstalando dependências do TubeClean (perdidas na reconstrução)"
bash "$(dirname "$0")/tubeclean-deps.sh"

echo ">>> Limpando imagens antigas"
docker image prune -f

echo "OK: atualização concluída"
