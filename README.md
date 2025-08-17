# Desafio Técnico - DevOps (Cubos)

Este projeto implementa um ambiente seguro e replicável usando **Docker** e **Terraform**.  
Ele contém três serviços principais:  

- **Frontend** → HTML estático servido pelo Nginx.  
- **Backend** → API em Node.js que consulta o banco.  
- **PostgreSQL 15.8** → Base de dados com script de inicialização.  

Além disso, o **Nginx atua como proxy reverso** para expor o frontend e rotear chamadas `/api` para o backend.

---

## Estrutura do Projeto
desafio-tecnico/
│
├── backend/ # API em Node.js
│ ├── index.js
│ ├── package.json
│ ├── Dockerfile
│
├── frontend/ # Página HTML
│ ├── index.html
│ ├── Dockerfile
│
├── nginx/ # Configuração do Proxy
│ └── nginx.conf
│
├── database/ # Script inicial do banco
│ └── init.sql
│
├── terraform/ # Infra com Docker Provider
│ └── main.tf
│
└── .env # Variáveis de ambiente


---

## Dependências

Antes de rodar, certifique-se de ter instalado:  

- [Docker](https://docs.docker.com/get-docker/)  
- [Terraform](https://developer.hashicorp.com/terraform/downloads)  
- [Git](https://git-scm.com/downloads)  

---

## ▶️ Como rodar

1. Clone este repositório:
   ```bash
   git clone https://github.com/seu-usuario/desafio-tecnico.git
   cd desafio-tecnico

   cd desafio-tecnico

2. Crie o arquivo .env (já existe um modelo pronto no repositório):

cp .env.example .env

3. Aplique a infraestrutura com Terraform:

cd terraform
terraform init
terraform apply -auto-approve

4. Acesse no navegador:

http://localhost