# togglemaster-gitops

Repositório GitOps do ToggleMaster — contém todos os manifests Kubernetes gerenciados pelo ArgoCD.

## Estrutura

```
togglemaster-gitops/
├── argocd/
│   ├── applications.yaml   # ArgoCD Applications (uma por serviço + base)
│   └── install.sh          # Script de instalação do ArgoCD no cluster
│
├── base/
│   ├── namespace.yaml      # Namespace tech-challenge
│   ├── ingress/
│   │   └── ingress.yaml    # Ingress NGINX com roteamento por path
│   └── secrets/
│       ├── .env.example    # Template de variáveis (commitar)
│       ├── .env            # Valores reais — gitignored
│       ├── apply-secrets.sh
│       └── README.md
│
└── apps/
    ├── auth-service/
    ├── flag-service/
    ├── targeting-service/
    ├── evaluation-service/
    └── analytics-service/
        ├── deployment.yaml
        ├── service.yaml
        └── hpa.yaml
```

## Serviços

| Serviço | Porta | Path (Ingress) | Secret |
|---------|-------|----------------|--------|
| auth-service | 8001 | `/auth` | `auth-db-secret` |
| flag-service | 8002 | `/flags` | `flag-db-secret` |
| targeting-service | 8003 | `/targeting` | `targeting-db-secret` |
| evaluation-service | 8004 | `/evaluate` | — |
| analytics-service | 8005 | `/analytics` | `aws-secret` |

Cada serviço possui `Deployment`, `Service` e `HPA` (min: 2 / max: 6 réplicas, escala em 70% de CPU).

## Primeiro deploy

### 1. Instalar o ArgoCD e registrar as Applications

```bash
bash argocd/install.sh
```

O script instala o ArgoCD, aguarda os pods subirem, aplica as Applications e exibe a senha inicial do admin.

### 2. Aplicar os secrets

Os secrets **não são sincronizados pelo ArgoCD** — devem ser aplicados antes de subir os serviços.

```bash
cd base/secrets
cp .env.example .env
# preencha o .env com os valores reais
bash apply-secrets.sh
```

Veja [base/secrets/README.md](base/secrets/README.md) para detalhes de cada variável.

### 3. Acessar o ArgoCD

Após o `install.sh`, o port-forward já estará ativo:

```
URL:     https://localhost:8080
Usuário: admin
Senha:   (exibida ao final do install.sh)
```

## Atualizando imagens

Os deployments referenciam a imagem com a tag `IMAGE_TAG`:

```
ACCOUNT_ID.dkr.ecr.us-east-1.amazonaws.com/togglemaster/<service>:IMAGE_TAG
```

Substitua `ACCOUNT_ID` e `IMAGE_TAG` pelo ID da conta AWS e pela tag desejada (ex: hash do commit). O ArgoCD detecta a mudança no repositório e aplica automaticamente.
