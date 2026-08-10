# Ordem OS API

## Visão geral

A Ordem OS API é uma aplicação em Ruby on Rails voltada para a gestão de ordens de serviço, com foco em operação de manutenção, suporte técnico e atendimento ao cliente.

O sistema centraliza o ciclo de vida de uma ordem de serviço, incluindo cadastro de clientes, equipamentos, serviços, técnicos, status, prioridades, endereços e laudos.

## Objetivo

O objetivo principal da API é permitir que uma empresa controle e acompanhe os atendimentos realizados, desde a abertura da ordem até o fechamento do serviço, mantendo os dados organizados e acessíveis por meio de endpoints REST.

## Módulos principais

### 1. Clientes
Responsável pelo cadastro dos clientes e pelos dados complementares relacionados:
- endereço;
- telefones;
- equipamentos;
- ordens de serviço.

Arquivos principais:
- app/models/cliente.rb
- app/controllers/api/v1/clientes_controller.rb

### 2. Endereços e contatos
Modelos usados para registrar endereço e contatos do cliente.

Arquivos principais:
- app/models/endereco.rb
- app/models/telefone.rb

### 3. Equipamentos
Gerencia os equipamentos vinculados ao cliente e sua participação nas ordens de serviço.

Arquivos principais:
- app/models/equipamento.rb
- app/models/os_equipamento.rb

### 4. Serviços e categorias
Define o catálogo de serviços prestados pela empresa.

Arquivos principais:
- app/models/servico.rb
- app/models/categorias_servico.rb
- app/controllers/api/v1/servicos_controller.rb

### 5. Técnicos
Controla os profissionais responsáveis pela execução do atendimento.

Arquivos principais:
- app/models/tecnico.rb
- app/models/os_tecnico.rb
- app/controllers/api/v1/tecnicos_controller.rb

### 6. Ordens de serviço
É o módulo central da aplicação.

Arquivos principais:
- app/models/ordem_servico.rb
- app/controllers/api/v1/ordem_servicos_controller.rb

A ordem de serviço concentra:
- cliente;
- status;
- prioridade;
- endereço;
- técnicos;
- serviços;
- equipamentos;
- observações;
- laudos;
- tarefas.

### 7. Status e prioridade
Classificam o andamento e a urgência das ordens.

Arquivos principais:
- app/models/status.rb
- app/models/prioridade.rb

### 8. Autenticação e autorização
A API possui autenticação via JWT e controle baseado em papel do usuário.

Arquivos principais:
- app/controllers/api/v1/base_controller.rb
- app/controllers/api/v1/sessions_controller.rb
- app/models/user.rb

## Arquitetura

O projeto usa a arquitetura padrão do Rails, com API REST e Active Record para persistência e relacionamento entre entidades.

Estrutura principal:
- app/controllers: controllers da API
- app/models: modelos e regras de negócio
- config/routes.rb: definição das rotas
- db/migrate: migrações do banco
- app/serializers: serializers para respostas JSON

## Rotas principais

A API está versionada em /api/v1 e inclui recursos como:
- clientes
- equipamentos
- serviços
- categorias de serviço
- status
- técnicos
- ordens de serviço
- prioridades
- login

Arquivo de rotas:
- config/routes.rb

## Fluxo principal do sistema

1. Cadastro do cliente
2. Cadastro do endereço e telefone
3. Cadastro dos equipamentos
4. Criação da ordem de serviço
5. Vinculação de técnicos e serviços
6. Atualização do status da ordem
7. Registro de laudos e fechamento do atendimento

## Tecnologias

- Ruby on Rails
- PostgreSQL
- JWT para autenticação
- Rails API

## Como executar

### Requisitos
- Ruby
- Bundler
- PostgreSQL

### Instalação

```bash
bundle install
rails db:create
rails db:migrate
rails server
```

### Executar testes

```bash
rails test
```

## Considerações finais

Este projeto foi estruturado para ser uma API de negócios para gestão operacional de atendimentos, sendo o módulo central de ordens de serviço o principal ponto de foco da aplicação.
