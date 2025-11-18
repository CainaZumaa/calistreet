# Calistreet

Bem-vindo ao Calistreet, seu aplicativo de calistenia para acompanhar e gerenciar seus treinos!

## Sobre o Projeto

Calistreet é um aplicativo móvel desenvolvido com Flutter que permite aos usuários criar, acompanhar e gerenciar seus treinos de calistenia. Com uma interface intuitiva e recursos essenciais, o Calistreet ajuda você a se manter motivado e a alcançar seus objetivos de fitness.

## Funcionalidades

- **Criação de Treinos Personalizados:** Monte seus próprios treinos com exercícios, séries e repetições customizáveis.
- **Acompanhamento de Treinos:** Registre seus treinos em tempo real, marcando exercícios concluídos.
- **Visualização de Progresso:** Acompanhe seu desempenho ao longo do tempo.
- **Biblioteca de Exercícios:** Explore uma vasta biblioteca de exercícios de calistenia com descrições e níveis de dificuldade.
- **Agendamento de Treinos:** Defina dias específicos para cada treino.

## Instalação

Para configurar e rodar o projeto localmente, siga os passos abaixo:

### Pré-requisitos

Certifique-se de ter o Flutter SDK instalado e configurado em sua máquina. Você pode encontrar as instruções de instalação [aqui](https://flutter.dev/docs/get-started/install).

### Passos

1.  **Clone o repositório:**
    ```bash
    git clone https://github.com/seu-usuario/calistreet.git
    cd calistreet
    ```

2.  **Instale as dependências:**
    ```bash
    flutter pub get
    ```

3.  **Configure o Supabase:**
    Este projeto utiliza Supabase como backend. Você precisará configurar seu próprio projeto Supabase e atualizar as credenciais no arquivo `lib/config/supabase_config.dart`.

    - Crie um novo projeto no [Supabase](https://app.supabase.io/).
    - Obtenha sua `SUPABASE_URL` e `SUPABASE_ANON_KEY`.
    - Atualize o arquivo `lib/config/supabase_config.dart` com suas credenciais:
        ```dart
        // lib/config/supabase_config.dart
        class SupabaseConfig {
          static const String supabaseUrl = 'SUA_SUPABASE_URL';
          static const String supabaseAnonKey = 'SUA_SUPABASE_ANON_KEY';
        }
        ```
    - Execute as migrações do Supabase localmente ou no seu projeto Supabase. Os arquivos de migração estão em `supabase/migrations/`.

4.  **Execute o aplicativo:**
    ```bash
    flutter run
    ```

## Uso

Após a instalação, você pode:
- Criar uma conta ou fazer login.
- Navegar pela biblioteca de exercícios.
- Criar novos treinos personalizados.
- Iniciar e acompanhar seus treinos.
- Visualizar seu progresso.

## Contribuição

Contribuições são bem-vindas! Se você deseja contribuir, por favor, siga estes passos:

1.  Faça um fork do repositório.
2.  Crie uma nova branch (`git checkout -b feature/sua-feature`).
3.  Faça suas alterações e commit (`git commit -am 'feat: Adiciona nova funcionalidade'`).
4.  Envie para a branch (`git push origin feature/sua-feature`).
5.  Abra um Pull Request.