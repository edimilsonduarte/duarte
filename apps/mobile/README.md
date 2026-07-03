# App Mobile (React Native)

Esta pasta é reservada para o app React Native. O app **não roda no VPS** — ele é distribuído pelas lojas (Google Play / App Store) e consome as APIs do VPS pela internet.

## Como iniciar o projeto

Recomendado usar **Expo** (mais simples para builds e publicação):

```bash
cd apps/mobile
npx create-expo-app@latest . --template blank-typescript
```

## Integração com as APIs do VPS

Crie um cliente central de API apontando para o domínio do VPS:

```ts
// src/api/client.ts
const BASE_URL = 'https://SEU_DOMINIO.com';

export async function apiNode(path: string, init?: RequestInit) {
  const res = await fetch(`${BASE_URL}/api/node${path}`, init);
  if (!res.ok) throw new Error(`Erro ${res.status}`);
  return res.json();
}

export async function apiPython(path: string, init?: RequestInit) {
  const res = await fetch(`${BASE_URL}/api/python${path}`, init);
  if (!res.ok) throw new Error(`Erro ${res.status}`);
  return res.json();
}
```

Exemplo de uso:

```ts
const status = await apiNode('/health'); // { status: 'ok', service: 'api-node' }
```

## Importante

- **HTTPS é obrigatório** em produção: iOS (App Transport Security) e Android bloqueiam HTTP por padrão. Configure o HTTPS no VPS antes de publicar (veja `docs/SETUP-VPS.md`).
- Durante o desenvolvimento local, você pode apontar `BASE_URL` para `http://SEU_IP_LOCAL:8080` com o ambiente dev (`docker compose up`) rodando.
- Builds e publicação: use o **EAS Build** (`npx eas build`) — não depende do VPS.
