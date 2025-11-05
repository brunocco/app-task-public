# 🏠 Roteiro para Executar o App-Task Localmente

Guia completo para executar o projeto **App-Task** em ambiente local usando Docker Compose.

## 📋 Pré-requisitos

Antes de começar, certifique-se de ter instalado:

- **Git** (v2.x ou superior)
- **Docker** (v20.x ou superior)
- **Docker Compose** (v2.x ou superior)

### Verificar instalações:
```bash
git --version
docker --version
docker-compose --version
```

---

## 🚀 Passo a Passo

### 1️⃣ Clonar o Repositório

```bash
# Clone o repositório
git clone https://github.com/brunocco/app-task-public.git

# Entre no diretório do projeto
cd app-task
```

### 2️⃣ Verificar a Estrutura do Projeto

```bash
# Listar arquivos do projeto
ls -la

# Estrutura esperada:
# ├── backend/          # API Node.js + Express
# ├── frontend/         # Interface HTML + JavaScript
# ├── infra/           # Terraform (não usado localmente)
# ├── docker-compose.yml # Orquestração dos containers
# └── README.md        # Documentação principal
```

### 3️⃣ Executar com Docker Compose

```bash
# Construir e executar todos os serviços
docker-compose up --build

# Ou executar em background (detached)
docker-compose up --build -d
```

**O que acontece:**
- 🗄️ **PostgreSQL** inicia na porta `5432`
- 🔧 **Backend** (Node.js) inicia na porta `3000`
- 🌐 **Frontend** (Nginx) inicia na porta `8080`

### 4️⃣ Aguardar Inicialização

Aguarde até ver as mensagens:
```
backend_1   | Server running on port 3000
frontend_1  | /docker-entrypoint.sh: Configuration complete
db_1        | database system is ready to accept connections
```

### 5️⃣ Acessar a Aplicação

Abra o navegador e acesse:
```
http://localhost:8080
```

**Funcionalidades disponíveis:**
- ✅ Adicionar nova tarefa
- ✅ Marcar tarefa como concluída
- ✅ Deletar tarefa
- ✅ Listar todas as tarefas

---

## 🐳 Serviços em Execução

| Serviço | Porta | URL | Descrição |
|---------|-------|-----|----------|
| **Frontend** | 8080 | http://localhost:8080 | Interface web da aplicação |
| **Backend** | 3000 | http://localhost:3000/tasks | API REST para gerenciar tarefas |
| **Database** | 5432 | localhost:5432 | PostgreSQL (tasksdb) |

---

## 🧪 Testar a API Diretamente

### Listar todas as tarefas:
```bash
curl http://localhost:3000/tasks
```

### Adicionar nova tarefa:
```bash
curl -X POST http://localhost:3000/tasks \
  -H "Content-Type: application/json" \
  -d '{"title": "Minha primeira tarefa", "completed": false}'
```

### Marcar tarefa como concluída:
```bash
curl -X PUT http://localhost:3000/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"completed": true}'
```

### Deletar tarefa:
```bash
curl -X DELETE http://localhost:3000/tasks/1
```

---

## 🔍 Comandos Úteis

### Ver logs dos containers:
```bash
# Todos os serviços
docker-compose logs

# Apenas o backend
docker-compose logs backend

# Seguir logs em tempo real
docker-compose logs -f
```

### Verificar status dos containers:
```bash
docker-compose ps
```

### Parar os serviços:
```bash
# Parar containers (mantém volumes)
docker-compose down

# Parar e remover volumes (apaga dados do banco)
docker-compose down -v
```

### Reconstruir containers:
```bash
# Forçar rebuild das imagens
docker-compose up --build --force-recreate
```

### Acessar container do banco:
```bash
# Conectar ao PostgreSQL
docker-compose exec db psql -U postgres -d tasksdb

# Comandos SQL úteis:
# \dt          - listar tabelas
# SELECT * FROM tasks; - ver todas as tarefas
# \q           - sair
```

---

## 🛠️ Troubleshooting

### Problema: Porta já em uso
```bash
# Verificar processos usando as portas
netstat -tulpn | grep :8080
netstat -tulpn | grep :3000
netstat -tulpn | grep :5432

# Parar processo específico
sudo kill -9 <PID>
```

### Problema: Container não inicia
```bash
# Ver logs detalhados
docker-compose logs <nome-do-servico>

# Reconstruir do zero
docker-compose down -v
docker-compose up --build
```

### Problema: Banco de dados não conecta
```bash
# Verificar se o PostgreSQL está rodando
docker-compose ps

# Testar conexão manual
docker-compose exec backend ping db
```

### Problema: Frontend não carrega
```bash
# Verificar se o backend está respondendo
curl http://localhost:3000/tasks

# Verificar logs do frontend
docker-compose logs frontend
```

---

## 📊 Estrutura do Banco de Dados

O banco PostgreSQL é criado automaticamente com a tabela:

```sql
CREATE TABLE tasks (
    id SERIAL PRIMARY KEY,
    title VARCHAR(255) NOT NULL,
    completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
```

**Dados de conexão:**
- Host: `localhost` (ou `db` dentro dos containers)
- Porta: `5432`
- Database: `tasksdb`
- Usuário: `postgres`
- Senha: `postgres`

---

## 🔄 Desenvolvimento Local

### Modificar código sem rebuild:

1. **Backend**: Edite arquivos em `./backend/`
2. **Frontend**: Edite arquivos em `./frontend/`
3. **Reiniciar apenas o serviço modificado**:
   ```bash
   docker-compose restart backend
   # ou
   docker-compose restart frontend
   ```

### Adicionar dependências no backend:
```bash
# Acessar container do backend
docker-compose exec backend bash

# Instalar nova dependência
npm install <pacote>

# Sair do container
exit

# Reconstruir para persistir mudanças
docker-compose up --build backend
```

---

## 🧹 Limpeza Completa

Para remover tudo e começar do zero:

```bash
# Parar e remover containers, redes e volumes
docker-compose down -v

# Remover imagens criadas
docker rmi app-task_backend app-task_frontend

# Limpar cache do Docker (opcional)
docker system prune -a
```

---

## ✅ Checklist de Verificação

- [ ] Git, Docker e Docker Compose instalados
- [ ] Repositório clonado com sucesso
- [ ] `docker-compose up --build` executado sem erros
- [ ] Frontend acessível em http://localhost:8080
- [ ] Backend respondendo em http://localhost:3000/tasks
- [ ] Possível adicionar, editar e deletar tarefas
- [ ] Dados persistem após reiniciar containers

---

## 🎯 Próximos Passos

Após testar localmente, você pode:

1. **Deploy na AWS**: Seguir o `README.md` principal
2. **Modificar código**: Personalizar frontend/backend
3. **Adicionar features**: Autenticação, categorias, etc.
4. **Configurar CI/CD**: GitHub Actions ou AWS CodePipeline

---

## 📞 Suporte

Se encontrar problemas:

1. Verifique os logs: `docker-compose logs`
2. Consulte a seção **Troubleshooting** acima
3. Abra uma issue no GitHub do projeto
4. Entre em contato: bruno_cco@hotmail.com

---

**🎉 Parabéns! Sua aplicação App-Task está rodando localmente!**
