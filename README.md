# Duarte — Plataforma multi-stack

Monorepo preparado para desenvolvimento **de qualquer ambiente** (Claude Code na web, celular, desktop) com deploy automático no VPS via Docker Compose.

## Arquitetura

```
                         ┌─────────────────────────────┐
  Push no GitHub ──────► │ GitHub Actions              │
  (branch main)          │  1. Build das imagens Docker│
                         │  2. Push para GHCR          │
                         │  3. SSH no VPS → compose up │
                         └──────────────┬──────────────┘
                                        │ SSH
                                        ▼
┌───────────────────────────── VPS ─────────────────────────────┐
│                     proxy (nginx) :80                         │
│        ┌──────────────┼──────────────────┐                    │
│        ▼              ▼                  ▼                    │
│   web-php:80    api-node:3000     api-python:8000             │
│   (site/painel) (/api/node/...)   (/api/python/...)           │
└───────────────────────────────────────────────────────────────┘
                                        ▲
                                        │ HTTPS
                          App React Native (apps/mobile)
                          consome as APIs pela internet
```

## Estrutura do repositório

| Caminho | O que é |
|---|---|
| `apps/api-node/` | API em Node.js (porta 3000) |
| `apps/api-python/` | API em Python/FastAPI (porta 8000) |
| `apps/web-php/` | Site/painel em PHP (Apache) |
| `apps/mobile/` | App React Native (consome as APIs; não roda no VPS) |
| `proxy/` | Nginx que roteia as requisições entre os serviços |
| `docker-compose.yml` | Ambiente de **desenvolvimento** (builda tudo localmente) |
| `docker-compose.prod.yml` | Ambiente de **produção** no VPS (usa imagens do GHCR) |
| `deploy/` | Scripts usados no VPS |
| `.github/workflows/` | CI (build nas PRs) e Deploy (push na main) |
| `docs/SETUP-VPS.md` | Passo a passo para configurar o VPS e os secrets |

## Como rodar localmente

Precisa apenas de Docker instalado:

```bash
docker compose up --build
```

- Site PHP: http://localhost:8080/
- API Node: http://localhost:8080/api/node/health
- API Python: http://localhost:8080/api/python/health

## Como funciona o deploy

1. Você trabalha de qualquer lugar (web, celular, PC) e faz merge na branch `main`.
2. O GitHub Actions builda as imagens Docker e publica no GitHub Container Registry (GHCR).
3. O workflow conecta no VPS via SSH e roda `docker compose pull && up -d`.
4. O VPS passa a servir a nova versão — sem passos manuais.

Configuração inicial do VPS e dos secrets: veja **[docs/SETUP-VPS.md](docs/SETUP-VPS.md)**.
