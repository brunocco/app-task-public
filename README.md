# 🚀 App-Task - Aplicação Full-Stack na AWS com Terraform

## 📋 Introdução

**App-Task** é uma aplicação completa de gerenciamento de tarefas (To-Do List) desenvolvida com arquitetura moderna de microsserviços, containerizada com Docker e provisionada na AWS usando Terraform e ECS Fargate.

O projeto demonstra a implementação de uma infraestrutura cloud escalável, segura e de alta disponibilidade, seguindo as melhores práticas de DevOps e Cloud Computing.

### 🎯 Objetivos do Projeto

- Demonstrar provisionamento de infraestrutura como código (IaC) com Terraform
- Implementar arquitetura de microsserviços com containers Docker
- Utilizar serviços gerenciados da AWS (ECS Fargate, RDS, ALB)
- Aplicar conceitos de redes, segurança e observabilidade na nuvem
- Criar pipeline de deploy automatizado

---

## 📁 Estrutura de Pastas

```
app-task/
├── .amazonq/                    # Configurações do Amazon Q Agent
│   ├── cli-agents/
│   │   └── jarvis.json         # Agente DevOps Jarvis
│   └── rules/                  # Regras de infraestrutura
│       ├── docker-file.md
│       ├── infraestrutura.md
│       ├── naming.md
│       └── pipeline.md
├── backend/                     # API REST em Node.js
│   ├── migrations/
│   │   └── 001_create_tasks_table.sql
│   ├── app.js                  # Servidor Express
│   ├── Dockerfile              # Imagem Docker do backend
│   ├── package.json
│   └── package-lock.json
├── frontend/                    # Interface web
│   ├── app.js                  # Lógica JavaScript
│   ├── index.html              # Interface HTML
│   └── Dockerfile              # Imagem Docker do frontend
├── infra/                       # Infraestrutura como código
│   ├── main.tf                 # Configuração Terraform
│   ├── terraform.tfstate
│   └── terraform.tfstate.backup
├── deploy.bat                   # Script de deploy (Windows)
├── deploy.sh                    # Script de deploy (Linux/Mac)
├── docker-compose.yml           # Ambiente local
├── README.md                    # Documentação principal
└── Roteiro-rodar-local.md       # Guia para testar localmente
```

---

## 🛠️ Requisitos

### Ferramentas Necessárias

- **AWS CLI** (v2.x ou superior)
- **Terraform** (v1.0 ou superior)
- **Docker** (v20.x ou superior)
- **Git**
- **Conta AWS** com permissões administrativas
>Obs: mude no projeto a tag <SEU_ID_AWS_12DIGITOS> pelo seu id da sua conta AWS.

### Conhecimentos Recomendados

- Conceitos básicos de AWS (VPC, EC2, RDS, ECS)
- Docker e containerização
- Terraform (IaC)
- Node.js e Express
- PostgreSQL

---

## ☁️ Serviços AWS Utilizados

### Computação
- **Amazon ECS (Fargate)**: Orquestração de containers serverless
  - 2 serviços independentes (frontend e backend)
  - Task Definitions com 256 CPU / 512 MB RAM

### Rede
- **VPC**: Rede virtual isolada (10.0.0.0/16)
- **Subnets**: 2 públicas e 2 privadas em AZs diferentes
- **Internet Gateway**: Acesso à internet para subnets públicas
- **NAT Gateways**: Saída para internet das subnets privadas (2x para alta disponibilidade)
- **Application Load Balancer**: Balanceamento de carga HTTP com path-based routing

### Banco de Dados
- **Amazon RDS PostgreSQL 17**: Banco de dados gerenciado
  - Instância db.t3.micro
  - 20 GB de armazenamento gp2
  - Conexão SSL obrigatória

### Segurança
- **Security Groups**: Controle de tráfego granular
  - SG do ALB: Permite HTTP/HTTPS da internet
  - SG do ECS Backend: Permite porta 3000 apenas do ALB
  - SG do ECS Frontend: Permite porta 80 apenas do ALB
  - SG do RDS: Permite porta 5432 apenas do backend

### Armazenamento
- **Amazon ECR**: Registro privado de imagens Docker
  - app-task-backend
  - app-task-frontend

### Observabilidade
- **CloudWatch Logs**: Logs centralizados
  - `/ecs/app-task/backend`
  - `/ecs/app-task/frontend`

### Gerenciamento
- **IAM Roles**: Permissões para ECS Task Execution

---

## 🔄 Roteiro de Replicação e Teste

### 1️⃣ Clonar o Repositório

```bash
git clone https://github.com/brunocco/app-task.git
cd app-task
```

### 2️⃣ Configurar AWS CLI

```bash
# Configure suas credenciais AWS
aws configure

# Insira:
# - AWS Access Key ID
# - AWS Secret Access Key
# - Default region: us-east-1
# - Default output format: json
```

### 3️⃣ Criar Repositórios ECR

```bash
aws ecr create-repository --repository-name app-task-backend --region us-east-1
aws ecr create-repository --repository-name app-task-frontend --region us-east-1
```

### 4️⃣ Atualizar Account ID no Terraform

Edite `infra/main.tf` e substitua `<SEU_ID_AWS_12DIGITOS>` pelo seu AWS Account ID nas seguintes linhas:
- Task Definition do backend (linha ~450)
- Task Definition do frontend (linha ~490)

Ou execute:
```bash
# Linux/Mac
ACCOUNT_ID=$(aws sts get-caller-identity --query Account --output text)
sed -i "s/<SEU_ID_AWS_12DIGITOS>/$ACCOUNT_ID/g" infra/main.tf

# Windows PowerShell
$ACCOUNT_ID = (aws sts get-caller-identity --query Account --output text)
(Get-Content infra/main.tf) -replace '<SEU_ID_AWS_12DIGITOS>', $ACCOUNT_ID | Set-Content infra/main.tf
```

### 5️⃣ Provisionar Infraestrutura com Terraform

```bash
cd infra

# Inicializar Terraform
terraform init

# Validar configuração
terraform validate

# Visualizar plano de execução
terraform plan

# Aplicar infraestrutura (aguarde ~10 minutos)
terraform apply -auto-approve
```

**Recursos criados:**
- 1 VPC
- 4 Subnets (2 públicas + 2 privadas)
- 1 Internet Gateway
- 2 NAT Gateways
- 4 Route Tables
- 1 ECS Cluster
- 2 ECS Services
- 2 Task Definitions
- 1 Application Load Balancer
- 2 Target Groups
- 4 Security Groups
- 1 RDS PostgreSQL
- 2 CloudWatch Log Groups
- 1 IAM Role

### 6️⃣ Build e Push das Imagens Docker

```bash
cd ..

# Windows
deploy.bat

# Linux/Mac
chmod +x deploy.sh
./deploy.sh
```

O script irá:
1. Fazer login no ECR
2. Build da imagem do backend
3. Tag e push da imagem do backend
4. Build da imagem do frontend
5. Tag e push da imagem do frontend

### 7️⃣ Forçar Deploy dos Serviços ECS

```bash
aws ecs update-service --cluster app-task-cluster --service app-task-backend-svc --force-new-deployment --region us-east-1

aws ecs update-service --cluster app-task-cluster --service app-task-frontend-svc --force-new-deployment --region us-east-1
```

Aguarde 2-3 minutos para os containers iniciarem.

### 8️⃣ Obter URL da Aplicação

```bash
cd infra
terraform output alb_dns_name
```

Exemplo de saída:
```
"app-task-alb-1234567890.us-east-1.elb.amazonaws.com"
```

### 9️⃣ Testar a Aplicação

Acesse no navegador:
```
http://<ALB_DNS_NAME>
```

**Funcionalidades:**
- ✅ Adicionar nova tarefa
- ✅ Marcar tarefa como concluída
- ✅ Deletar tarefa
- ✅ Listar todas as tarefas

## Troubleshooting via bash

### Verificar status dos serviços
```bash
aws ecs describe-services --cluster app-task-cluster --services app-task-backend-svc app-task-frontend-svc --region us-east-1
```

### Verificar tasks em execução
```bash
aws ecs list-tasks --cluster app-task-cluster --region us-east-1
```

### Verificar health checks
```bash
aws elbv2 describe-target-health --target-group-arn <TARGET_GROUP_ARN> --region us-east-1
```

### Ver logs
```bash
aws logs tail /ecs/app-task/backend --follow --region us-east-1
aws logs tail /ecs/app-task/frontend --follow --region us-east-1
```
---

## Troubleshooting com o Agente IA Jarvis

### Iniciar chat com o agente

 Instale o Amazon Q CLI em sua instancia(ver instalação na pasta ".amazonq/README.MD")

### Comando para ativar Agente Jarvis:
```bash
q chat --agent jarvis

# Pergunte algo em relação ao seu projeto seja atualizar, acrescentar, retirar, diagnosticar:
# Exemplos de comandos:
# - "Revise a configuração do Terraform"
# - "Sugira melhorias de segurança"
# - "Como otimizar custos da infraestrutura?"
# - "Explique o roteamento do ALB"
# - "Verifique os logs do backend"
# - "Como adiciono um ambinte de stagging e produção no projeto?"
# - "Como implemento CICD nesse projeto com AWS ou GitActions?"
# - "Quero que mude meu projeto e adicione mais 1 listener para "/About""
```
---
## Troubleshooting com Cloud Watch:

- Acesse CloudWatch/Logs group/Log stream/app-task e verifique os logs.
  - `/ecs/app-task/backend`
  - `/ecs/app-task/frontend`
- Acesso o CloudWatch container insights e verifique tasks, uso CPU, graficos e etc.

---

## 📸 Prints Importantes

### 1. Imagens no ECR
- Acesse: AWS Console → ECR → Repositories
- Verifique: `app-task-backend` e `app-task-frontend` com tag `latest`

### 2. Tasks nos Services
- Acesse: AWS Console → ECS → Clusters → app-task-cluster
- Verifique: 2 services rodando (backend-svc e frontend-svc)
- Status: RUNNING com 1/1 tasks

### 3. Resource Map no Load Balancer
- Acesse: AWS Console → EC2 → Load Balancers → app-task-alb → Resource Map
- Verifique: 2 Target Groups (backend-tg e frontend-tg)
- Health Status: Healthy

### 4. Aplicação Rodando
- Acesse a URL do ALB no navegador
- Teste: Adicionar, completar e deletar tarefas
- Verifique: Dados persistem no RDS PostgreSQL

---

## 🧹 Limpeza de Recursos

Para evitar custos, destrua a infraestrutura após os testes:

```bash
cd infra
terraform destroy -auto-approve
```

**Atenção:** Isso irá deletar TODOS os recursos, incluindo o banco de dados.

---

## 🏗️ Arquitetura da Solução

```
Internet
    ↓
Application Load Balancer (Subnets Públicas)
    ↓
    ├─→ / → Frontend (Nginx) ────────┐
    │                                 │
    └─→ /tasks* → Backend (Node.js) ─┤
                        ↓             │
                   RDS PostgreSQL     │
                   (Subnets Privadas) │
                                      │
                   ECS Fargate ←──────┘
                   (Subnets Privadas)
                        ↓
                   NAT Gateway
                        ↓
                   Internet Gateway
```

---

## 💡 Melhorias Futuras

- [ ] Implementar HTTPS com ACM (Você precisa comprar um dominio sugestão Registro.br)
- [ ] Adicionar Auto Scaling para ECS Services (Testar escalabilidade)
- [ ] Configurar CI/CD com GitHub Actions ou CodePipeline
- [ ] Implementar backup automático do RDS
- [ ] Adicionar CloudWatch Alarms e SNS
- [ ] Implementar WAF para proteção do ALB
- [ ] Usar Secrets Manager para credenciais do RDS
- [ ] Adicionar testes automatizados
- [ ] Implementar deploy Blue/Green
- [ ] Adicionar cache com ElastiCache Redis

---

## 📚 Referências

- [AWS ECS Documentation](https://docs.aws.amazon.com/ecs/)
- [Terraform AWS Provider](https://registry.terraform.io/providers/hashicorp/aws/latest/docs)
- [Docker Documentation](https://docs.docker.com/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)

---

## 🎓 Conclusão

Este projeto demonstra a implementação completa de uma aplicação cloud-native na AWS, desde o desenvolvimento local com Docker Compose até o deploy em produção com ECS Fargate e Terraform.

A arquitetura implementada é escalável, segura e segue as melhores práticas de DevOps e Cloud Computing, sendo ideal para portfólio profissional e aprendizado de tecnologias modernas.

**Principais aprendizados:**
- Provisionamento de infraestrutura como código com Terraform
- Containerização de aplicações com Docker
- Orquestração de containers com ECS Fargate
- Configuração de redes e segurança na AWS
- Integração de serviços gerenciados (RDS, ALB, ECR)
- Observabilidade com CloudWatch Logs

---

## 👤 Autor

**Bruno Cesar**

- 📧 Email: [bruno_cco@hotmail.com]
- 💼 LinkedIn: [linkedin.com/in/bbruno-cesar-704265223/](https://www.linkedin.com/in/bruno-cesar-704265223/)
- 📝 Medium: [medium.com/@brunosherlocked](https://medium.com/@brunosherlocked)
- 🐙 GitHub: [github.com/brunocco](https://github.com/brunocco)

---

## 📅 Data

**Novembro de 2025**

---

## 📄 Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.

---

⭐ Se este projeto foi útil para você, considere dar uma estrela no GitHub!
