#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="$SCRIPT_DIR/.env"
NAMESPACE="tech-challenge"

if [[ ! -f "$ENV_FILE" ]]; then
  echo "Erro: arquivo .env não encontrado em $SCRIPT_DIR"
  echo "Crie-o a partir do template: cp .env.example .env"
  exit 1
fi

# Carrega as variáveis do .env (ignora linhas em branco e comentários)
set -o allexport
# shellcheck disable=SC1090
source <(grep -v '^\s*#' "$ENV_FILE" | grep -v '^\s*$')
set +o allexport

echo "Aplicando secrets no namespace '$NAMESPACE'..."

kubectl create secret generic auth-db-secret \
  --namespace="$NAMESPACE" \
  --from-literal=DATABASE_URL="postgres://postgres:${AUTH_DB_PASSWORD}@${AUTH_RDS_ENDPOINT}:5432/postgres" \
  --from-literal=MASTER_KEY="${AUTH_MASTER_KEY}" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic flag-db-secret \
  --namespace="$NAMESPACE" \
  --from-literal=DATABASE_URL="postgres://postgres:${FLAG_DB_PASSWORD}@${FLAG_RDS_ENDPOINT}:5432/postgres" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic targeting-db-secret \
  --namespace="$NAMESPACE" \
  --from-literal=DATABASE_URL="postgres://postgres:${TARGETING_DB_PASSWORD}@${TARGETING_RDS_ENDPOINT}:5432/postgres" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic redis-secret \
  --namespace="$NAMESPACE" \
  --from-literal=REDIS_URL="redis://${REDIS_ENDPOINT}:6379" \
  --dry-run=client -o yaml | kubectl apply -f -

kubectl create secret generic aws-secret \
  --namespace="$NAMESPACE" \
  --from-literal=AWS_REGION="${AWS_REGION}" \
  --from-literal=AWS_SQS_URL="${AWS_SQS_URL}" \
  --from-literal=AWS_DYNAMODB_TABLE="ToggleMasterAnalytics" \
  --from-literal=AWS_ACCESS_KEY_ID="${AWS_ACCESS_KEY_ID}" \
  --from-literal=AWS_SECRET_ACCESS_KEY="${AWS_SECRET_ACCESS_KEY}" \
  --from-literal=AWS_SESSION_TOKEN="${AWS_SESSION_TOKEN}" \
  --dry-run=client -o yaml | kubectl apply -f -

echo "Secrets aplicados com sucesso!"
