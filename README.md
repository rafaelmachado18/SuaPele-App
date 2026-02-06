# Projeto Sua Pele - Documentação Técnica

## 1. Visão Geral
O **Sua Pele** é uma solução de software integrada para saúde dermatológica. O sistema permite o registro e monitoramento de lesões de pele, além do gerenciamento completo de planos de tratamento (medicamentos, consultas e rotinas fotográficas). O foco principal é facilitar a adesão do paciente ao tratamento e gerar um histórico clínico detalhado.

---

## 2. Backend e Arquitetura de Dados

### Tecnologias e Framework
* **Linguagem:** C# (.NET)
* **ORM:** Entity Framework Core (EF Core)
* **Abordagem:** Code-First (Classes C# definem o banco)

### Arquitetura
O sistema segue uma **Arquitetura em Camadas (Layered Architecture)**, separando rigidamente as responsabilidades:
1. **Apresentação:** Controllers (API).
2. **Lógica de Negócio:** Interfaces e Serviços.
3. **Acesso a Dados:** Repositórios e Contexto.

### Banco de Dados (PostgreSQL + Docker)
O banco de dados não é criado manualmente via SQL. Utilizamos o EF Core para gerenciar o esquema e aplicar mudanças via **Migrations** em um container **PostgreSQL** orquestrado pelo **Docker**.

---

## 3. Estrutura Lógica do Backend

### Camada de Repositório (Repository)
Responsável exclusiva pelo acesso direto aos dados.
* Executa operações CRUD (Create, Read, Update, Delete).
* Gerencia transações complexas (ex: garantir a exclusão de dependências, como lembretes, antes de excluir a entidade pai).
* Utiliza o `AppDbContext` para comunicação com o PostgreSQL.

### Camada de Controle (Controller)
Ponto de entrada da API REST.
* Recebe requisições HTTP do aplicativo Flutter.
* Processa regras de negócio.
* Realiza integrações externas:
    * **Serviços de E-mail:** Para notificações e confirmações.
    * **API Gemini (IA):** Para análise preliminar de dados e lesões.
* Retorna respostas padronizadas em JSON.

### Interfaces
O projeto utiliza Interfaces (ex: `ITratamentoRepository`) para definir contratos. Isso desacopla o Controller da implementação direta do banco, facilitando manutenção e testes futuros.

---

## 4. Infraestrutura e Configuração

### Docker e WebHost
O projeto é containerizado. O arquivo `Program.cs` configura o WebHost para operar dentro do ambiente Docker, gerenciando a injeção de dependência e o ciclo de vida dos serviços.

### Configuração de Conexão (Program.cs)
O sistema detecta automaticamente o ambiente para definir a String de Conexão:
* **Localhost:** Para desenvolvimento fora do container.
* **Host=db:** Para comunicação interna na rede Docker.

### Swagger
Ferramenta integrada para documentação e teste manual dos endpoints da API, permitindo validação das rotas antes da integração com o frontend.

---

## 5. Frontend (Mobile)

### Tecnologia
* **Framework:** Flutter (Dart).
* **Ambiente de Desenvolvimento:** Máquina Virtual (VM) Samsung API 33 (Android 13).

### Estrutura de Pastas
O código fonte foi organizado em módulos funcionais para escalabilidade:

- **analise/**: Lógica de IA e relatórios de lesões.
- **autenticacao/**: Login, Cadastro e Recuperação de Senha.
- **core/**: Configurações globais, rotas e constantes.
- **home/**: Dashboard principal.
- **manchas/**: CRUD de lesões e upload de fotos.
- **perfil/**: Gestão de usuário e logout.
- **tratamentos/**: Planos de cuidado, agenda e medicamentos.
- **widgets/**: Componentes visuais reutilizáveis.

### Arquivos Críticos
* **main.dart:** Inicialização do app, temas e injeção de serviços.
* **pubspec.yaml:** Gerenciamento de pacotes (dio, intl, flutter_local_notifications).
* **build.gradle:** Configurações de build do Android (SDK mínimo e permissões).

### Notificações Locais
Sistema sincronizado com o Backend para gerar alertas no dispositivo sobre horários de medicamentos, consultas e rotinas de fotos.

---

## 6. Guia de Execução

Siga os passos abaixo para iniciar o projeto completo (Backend + Frontend).

Caso Você saiba que o backend já está rodando em alguma máquina, só precisa inserir o endereço correto em `app_config.dart` e rodar o app no seu Android Studio

### Passo 1: Backend (Docker)

1. Abra o terminal na pasta raiz do Backend (SuaPeleBackend).
2. Suba os containers da API e do Banco de Dados:

```bash
docker-compose up --build api
```

#### Configuração Inicial do Banco

Abra um segundo terminal na mesma pasta do backend e execute a atualização das tabelas.

Necessário na primeira execução ou após resetar volumes.

```bash
dotnet ef database update
```

---

### Passo 2: Frontend (Flutter)

1. Abra o terminal na pasta raiz do Frontend (SuaPeleFrontend).

2. Instale as dependências:

```bash
flutter pub get
```

3. Certifique-se de que o emulador Android (API 33) esteja em execução.

4. Execute o aplicativo:

```bash
flutter run
```
