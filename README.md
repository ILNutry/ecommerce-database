# Projeto Lógico de Banco de Dados para E-commerce

## Descrição do Projeto

Este projeto foi desenvolvido como parte do desafio de modelagem lógica de banco de dados da DIO (Digital Innovation One), tendo como objetivo a implementação de um sistema de e-commerce utilizando MySQL 8.0.

O modelo foi refinado a partir do cenário proposto, incorporando regras de negócio adicionais relacionadas a clientes, pagamentos, entregas e relacionamentos entre entidades.

Além da modelagem lógica, foram implementadas consultas SQL para demonstrar a utilização de filtros, agregações, junções e cálculos derivados sobre os dados.

## Objetivos do Projeto

- Construir o modelo lógico de um sistema de e-commerce.
- Implementar relacionamentos entre entidades utilizando chaves primárias e estrangeiras.
- Aplicar conceitos de normalização.
- Realizar persistência de dados para testes.
- Desenvolver consultas SQL utilizando diferentes cláusulas.
- Demonstrar consultas analíticas sobre os dados do sistema.

## Regras de Negócio Implementadas

### Cliente Pessoa Física e Pessoa Jurídica

Um cliente pode ser cadastrado como:

- Pessoa Física (PF)
- Pessoa Jurídica (PJ)

Um cliente não pode possuir simultaneamente informações de PF e PJ.

### Formas de Pagamento

Um cliente pode possuir múltiplas formas de pagamento cadastradas.

Exemplos:

- Cartão de Crédito
- PIX
- Boleto Bancário

### Entrega

Cada pedido possui:

- Status da entrega
- Código de rastreio

## Principais Entidades

- cliente
- cliente_pf
- cliente_pj
- endereco_cliente
- forma_pagamento
- cliente_pagamento
- fornecedor
- vendedor
- produto
- vendedor_produto
- deposito
- estoque
- pedido
- pedido_item
- entrega

## Relacionamentos

- Cliente 1:N Endereço
- Cliente N:N Forma de Pagamento
- Fornecedor 1:N Produto
- Produto N:N Vendedor
- Pedido N:N Produto
- Pedido 1:1 Entrega

## Tecnologias Utilizadas

- MySQL 8.0
- MySQL Workbench
- SQL

## Consultas Implementadas

O projeto contém consultas utilizando:

- SELECT
- WHERE
- ORDER BY
- GROUP BY
- HAVING
- INNER JOIN
- LEFT JOIN
- Funções de agregação
- Atributos derivados

## Consulta Principal

A consulta principal integra:

- Cliente
- Pedido
- Produto
- Fornecedor
- Vendedor
- Entrega

Permitindo visualizar todo o fluxo de venda do e-commerce.

## Resultados Obtidos

O projeto demonstra:

- Modelagem lógica de banco de dados.
- Aplicação de chaves primárias e estrangeiras.
- Relacionamentos 1:1, 1:N e N:N.
- Especialização de entidades (PF/PJ).
- Controle de pagamentos e entregas.
- Consultas analíticas utilizando SQL.
- Manipulação e recuperação de dados em ambiente MySQL.

## Autor

Elton Silva Borges

Especialista em Logística, Supply Chain, Dados e Business Intelligence.
