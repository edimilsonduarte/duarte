# Configuração do VPS e do deploy automático

Siga estes passos **uma única vez**. Depois disso, todo merge na branch `main` faz deploy sozinho.

## 1. Preparar o VPS

Conecte no VPS via SSH e rode:

```bash
# Instalar Docker (Ubuntu/Debian)
curl -fsSL https://get.docker.com | sh

# Criar a pasta do projeto
sudo mkdir -p /opt/duarte
sudo chown $USER /opt/duarte

# Criar o arquivo de variáveis de ambiente
nano /opt/duarte/.env
# Cole o conteúdo baseado no .env.example do repositório e preencha os valores reais
```

## 2. Dar acesso do VPS ao GHCR (imagens Docker)

Se o repositório for **privado**, o VPS precisa se autenticar para baixar as imagens:

1. No GitHub: **Settings → Developer settings → Personal access tokens → Tokens (classic) → Generate new token**
2. Marque apenas o escopo **`read:packages`**.
3. No VPS, rode (substitua `SEU_TOKEN`):

```bash
echo "SEU_TOKEN" | docker login ghcr.io -u edimilsonduarte --password-stdin
```

Se o repositório for público e os pacotes também, este passo é dispensável.

## 3. Criar a chave SSH para o GitHub Actions

**No seu computador ou no próprio VPS**, gere um par de chaves dedicado ao deploy:

```bash
ssh-keygen -t ed25519 -C "github-actions-deploy" -f deploy_key -N ""
```

- Adicione a **chave pública** ao VPS:

```bash
cat deploy_key.pub >> ~/.ssh/authorized_keys
```

- A **chave privada** (`deploy_key`) vai para os secrets do GitHub no próximo passo. Depois de cadastrar, apague o arquivo local.

## 4. Cadastrar os secrets no GitHub

No repositório: **Settings → Secrets and variables → Actions → New repository secret**

| Secret | Valor |
|---|---|
| `VPS_HOST` | IP ou domínio do VPS (ex.: `203.0.113.10`) |
| `VPS_USER` | Usuário SSH (ex.: `root` ou `deploy`) |
| `VPS_SSH_KEY` | Conteúdo completo do arquivo `deploy_key` (chave **privada**) |
| `VPS_PORT` | Porta SSH — só cadastre se não for a 22 |

## 5. Testar

1. Faça merge de qualquer alteração na branch `main` (ou rode o workflow **Deploy** manualmente na aba Actions, botão *Run workflow*).
2. Acompanhe em **Actions → Deploy**.
3. Ao terminar, acesse `http://SEU_VPS/` — o site PHP deve responder, e as APIs em:
   - `http://SEU_VPS/api/node/health`
   - `http://SEU_VPS/api/python/health`

## HTTPS (recomendado antes de usar em produção)

A forma mais simples é apontar um domínio para o VPS e colocar um **Caddy** ou **Traefik** na frente, ou usar o Certbot. Exemplo rápido com Caddy substituindo o serviço `proxy` no `docker-compose.prod.yml`:

```yaml
  caddy:
    image: caddy:2-alpine
    ports: ["80:80", "443:443"]
    volumes:
      - ./Caddyfile:/etc/caddy/Caddyfile
      - caddy_data:/data
```

O app React Native **exige HTTPS** para falar com a API em produção (iOS bloqueia HTTP por padrão), então este passo é importante antes de publicar o app.

## Dia a dia (de qualquer ambiente)

- **Claude Code na web / celular**: abra uma sessão neste repositório, peça a alteração, revise a PR e faça o merge → deploy automático.
- **No PC**: clone o repositório, trabalhe normalmente, `git push` e merge na `main`.
- **Rollback**: as imagens também são publicadas com a tag do commit (`ghcr.io/.../api-node:<sha>`). Para voltar uma versão, edite a tag no `docker-compose.prod.yml` do VPS e rode `docker compose -f docker-compose.prod.yml up -d`.
