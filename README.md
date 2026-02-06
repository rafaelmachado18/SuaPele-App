Projeto Sua Pele - Documentação Técnica
1. O que é o Projeto
O Sua Pele é uma solução integrada de software focada na saúde dermatológica. O sistema permite que pacientes registrem, monitorem e gerenciem manchas na pele (lesões), além de organizarem seus planos de tratamento completos, incluindo medicamentos, consultas e rotinas fotográficas. O objetivo é facilitar a adesão ao tratamento e fornecer um histórico organizado para análise médica.

2. Backend e Arquitetura de Dados
Construção e Framework
O Backend foi construído utilizando a plataforma .NET com C#, fundamentado no Entity Framework Core (EF Core).

Adotamos uma Arquitetura em Camadas (Layered Architecture) para garantir a separação de responsabilidades e facilitar a manutenção. O sistema utiliza a abordagem Code-First do Entity Framework, onde nossas classes (Models) em C# definem a estrutura do banco de dados.

Banco de Dados PostgreSQL no Docker
Não criamos o banco de dados manualmente via SQL. Em vez disso, utilizamos o EF Core para gerar e migrar a estrutura das tabelas automaticamente para um container PostgreSQL rodando dentro do Docker.

Migrations: O versionamento do banco é controlado via Migrations do EF, garantindo que qualquer alteração no código C# (como adicionar uma coluna nova) seja refletida no Postgres de forma segura.

3. Estrutura Lógica do Backend
O Backend é dividido estrategicamente para isolar o acesso a dados da regra de negócios:

Camada de Repositório (Repository)
Esta camada é a única responsável por interagir com o banco de dados.

Ela executa as operações de CRUD (Create, Read, Update, Delete).

Utiliza o AppDbContext para conversar com o PostgreSQL.

Garante a integridade das transações (ex: apagar lembretes antes de apagar um tratamento).

Camada de Controle (Controller)
Os Controllers gerenciam a lógica da aplicação e atuam como o ponto de entrada da API.

Recebem as requisições HTTP da camada de apresentação (Flutter).

Processam as regras de negócio.

Integrações Externas: Conectam-se com serviços de E-mail (para alertas/confirmações) e com a API do Gemini (IA) para análise preliminar de dados.

Devolvem as respostas em formato JSON para o Frontend.

Uso de Interfaces
Utilizamos Interfaces em C# (ex: ITratamentoRepository, IPacienteRepository) para definir os contratos de nossos serviços.

Isso desacopla o código: o Controller não depende da implementação concreta, mas sim da interface.

Benefício: Facilita mudanças futuras (como trocar o banco de dados) e permite testes unitários mais fáceis, mantendo o projeto organizado e profissional.

4. Infraestrutura: Docker e Program.cs
Docker e WebHost
O projeto roda inteiramente containerizado. O Program.cs atua como o ponto de entrada que configura o WebHost dentro do ambiente Docker.

O Papel do Program.cs
No Program.cs, realizamos a configuração crítica da aplicação:

Conexão com Banco: Ele lê as variáveis de ambiente para decidir se conecta no localhost (desenvolvimento local) ou no Host=db (dentro da rede do Docker).

Injeção de Dependência: Configura o ciclo de vida dos Repositórios e Controllers, garantindo que o sistema instancie as classes corretamente quando necessário.

Entity Framework: Inicializa o contexto do banco de dados PostgreSQL.

Swagger
Para documentação e testes da API, integramos o Swagger. Ele fornece uma interface visual onde podemos testar todos os endpoints (GET, POST, DELETE) do Backend antes mesmo de conectar o Frontend, garantindo que a lógica do servidor esteja sólida.

5. Frontend (Mobile)
Desenvolvimento em Flutter
A interface do usuário foi criada após a definição do backend, utilizando o framework Flutter (Dart). O desenvolvimento e os testes foram realizados em uma Máquina Virtual (VM) emulando um smartphone Samsung com API 33 (Android 13), garantindo compatibilidade com dispositivos modernos.

Organização do Código (Pastas)
Para manter o código limpo e escalável, dividimos o projeto Flutter em 8 pastas principais:

analise: Telas e lógicas referentes à IA e relatórios das lesões.

autenticacao: Telas de Login, Cadastro e Recuperação de Senha.

core: Configurações globais, constantes (como URL da API) e serviços base.

home: A tela principal (Dashboard) do usuário.

manchas (Lesões): CRUD de lesões, upload de fotos e visualização.

perfil: Gerenciamento de dados do usuário e logout.

tratamentos: Gestão de planos de cuidado, medicamentos e agenda.

widgets: Componentes visuais reutilizáveis (botões customizados, cards, inputs).

Arquivos Essenciais
main.dart: O ponto de partida do app. Inicializa os serviços, configura rotas e define o tema visual.

pubspec.yaml: O gerenciador de dependências. É onde declaramos bibliotecas vitais como dio (para HTTP), intl (formatação de datas) e flutter_local_notifications.

build.gradle: Configuração de build do Android. Define a versão mínima do SDK e permissões necessárias para o app rodar no Android.

Sistema de Notificações
O Frontend possui um sistema de notificações locais robusto. Ele trabalha em conjunto com os Lembretes cadastrados no Backend para alertar o usuário sobre horários de medicamentos, consultas e rotinas de fotos, garantindo que o paciente não perca nenhuma etapa do tratamento.

6. Como Rodar o Projeto
Considerando que o ambiente Docker já está configurado, siga o caminho completo abaixo para iniciar a aplicação:

Parte 1: Inicialização do Backend e Banco de Dados
Abra o terminal na pasta raiz do Backend (SuaPeleBackend).

Certifique-se de que o Docker Desktop esteja em execução.

Execute o comando para construir e subir os containers (API e PostgreSQL):

Bash
docker-compose up --build api
(Aguarde até que o log indique que a API está ouvindo na porta configurada).

Atenção: Se o banco de dados foi resetado ou é a primeira execução, abra um segundo terminal na mesma pasta do Backend e execute a atualização das tabelas:

Bash
dotnet ef database update
(Isso garante que as tabelas existam no PostgreSQL antes do uso).

Parte 2: Inicialização do Frontend (Mobile)
Abra o terminal na pasta raiz do Frontend (SuaPeleFrontend).

Instale ou atualize as dependências do projeto Flutter:

Bash
flutter pub get
Inicie o emulador Android (API 33).

Execute o aplicativo no emulador:

Bash
flutter run
Após esses passos, o sistema estará totalmente operacional, com o Frontend conectado ao Backend via Docker.
