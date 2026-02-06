## Guia de Execução

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
