# Secrets

Gerenciamento de secrets do cluster para o namespace `tech-challenge`.

Os secrets **não são gerenciados pelo ArgoCD** — são aplicados manualmente ou via CI/CD, pois os valores reais ficam fora do repositório.

## Secrets disponíveis

| Nome | Chaves |
|------|--------|
| `auth-db-secret` | `DATABASE_URL`, `MASTER_KEY` |
| `flag-db-secret` | `DATABASE_URL` |
| `targeting-db-secret` | `DATABASE_URL` |
| `redis-secret` | `REDIS_URL` |
| `aws-secret` | `AWS_REGION`, `AWS_SQS_URL`, `AWS_DYNAMODB_TABLE`, `AWS_ACCESS_KEY_ID`, `AWS_SECRET_ACCESS_KEY`, `AWS_SESSION_TOKEN` |

## Como aplicar

```bash
cd base/secrets

# 1. Crie o .env a partir do template
cp .env.example .env

# 2. Preencha os valores reais no .env

# 3. Aplique no cluster
bash apply-secrets.sh
```

O script é idempotente — pode ser executado múltiplas vezes para atualizar os secrets.

## Arquivos

| Arquivo | Commitado | Descrição |
|---------|-----------|-----------|
| `.env.example` | Sim | Template com todos os placeholders |
| `.env` | **Não** | Valores reais — gitignored |
| `apply-secrets.sh` | Sim | Script que lê o `.env` e aplica os secrets via `kubectl` |
