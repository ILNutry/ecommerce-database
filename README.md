# 🛒 Projeto de Banco de Dados - E-commerce (Marketplace)

## 📌 Visão Geral
Modelagem de banco de dados relacional para um sistema de e-commerce com suporte a múltiplos vendedores (marketplace), controle de estoque distribuído e gestão de pedidos.

O modelo foi estruturado com foco em:
- Integridade referencial
- Normalização
- Escalabilidade

---

## 🧱 Modelo de Dados

### 🔑 Entidades e Chaves

| Tabela | PK | FKs |
|------|------|------|
| cliente | cliente_id | - |
| endereco_cliente | id | cliente_id → cliente |
| fornecedor | id | - |
| vendedor | id | - |
| produto | id | fornecedor_id → fornecedor |
| vendedor_produto | id | vendedor_id → vendedor / produto_id → produto |
| deposito | id | - |
| estoque | id | produto_id → produto / deposito_id → deposito |
| pedido | id | cliente_id → cliente / endereco_entrega_id → endereco_cliente |
| pedido_item | id | pedido_id → pedido / produto_id → produto / vendedor_id → vendedor |

---

## 📐 Cardinalidade dos Relacionamentos

- **Cliente 1:N Endereço**
- **Fornecedor 1:N Produto**
- **Produto N:N Vendedor** (via vendedor_produto)
- **Produto 1:N Estoque**
- **Depósito 1:N Estoque**
- **Cliente 1:N Pedido**
- **Pedido 1:N Pedido_Item**
- **Produto 1:N Pedido_Item**
- **Vendedor 1:N Pedido_Item**

---

## 🧩 DDL SQL (Estrutura do Banco)

```sql
CREATE TABLE cliente (
    cliente_id UUID PRIMARY KEY,
    cpf VARCHAR(14),
    cnpj VARCHAR(18),
    nome VARCHAR(255),
    email VARCHAR(255),
    forma_pagamento VARCHAR(50),
    created_at TIMESTAMP
);

CREATE TABLE endereco_cliente (
    id UUID PRIMARY KEY,
    cliente_id UUID,
    cep VARCHAR(10),
    logradouro VARCHAR(255),
    numero VARCHAR(20),
    complemento VARCHAR(255),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    uf VARCHAR(2),
    created_at TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id)
);

CREATE TABLE fornecedor (
    id UUID PRIMARY KEY,
    nome VARCHAR(255),
    cnpj VARCHAR(18),
    email VARCHAR(255),
    telefone VARCHAR(20),
    created_at TIMESTAMP
);

CREATE TABLE vendedor (
    id UUID PRIMARY KEY,
    nome VARCHAR(255),
    cnpj VARCHAR(18),
    email VARCHAR(255),
    created_at TIMESTAMP
);

CREATE TABLE produto (
    id UUID PRIMARY KEY,
    fornecedor_id UUID,
    sku VARCHAR(50),
    nome VARCHAR(255),
    descricao TEXT,
    preco_base INTEGER,
    ativo BOOLEAN,
    created_at TIMESTAMP,
    FOREIGN KEY (fornecedor_id) REFERENCES fornecedor(id)
);

CREATE TABLE vendedor_produto (
    id UUID PRIMARY KEY,
    vendedor_id UUID,
    produto_id UUID,
    preco_vendedor NUMERIC(10,2),
    ativo BOOLEAN,
    created_at TIMESTAMP,
    FOREIGN KEY (vendedor_id) REFERENCES vendedor(id),
    FOREIGN KEY (produto_id) REFERENCES produto(id)
);

CREATE TABLE deposito (
    id UUID PRIMARY KEY,
    nome VARCHAR(255),
    cidade VARCHAR(100),
    uf VARCHAR(2),
    created_at TIMESTAMP
);

CREATE TABLE estoque (
    id UUID PRIMARY KEY,
    produto_id UUID,
    deposito_id UUID,
    quantidade INTEGER,
    atualizado_em TIMESTAMP,
    FOREIGN KEY (produto_id) REFERENCES produto(id),
    FOREIGN KEY (deposito_id) REFERENCES deposito(id)
);

CREATE TABLE pedido (
    id UUID PRIMARY KEY,
    cliente_id UUID,
    endereco_entrega_id UUID,
    status_entrega VARCHAR(50),
    cancelado_em TIMESTAMP,
    frete_valor NUMERIC(10,2),
    total_itens NUMERIC(10,2),
    total_pedido NUMERIC(10,2),
    devolucao_ate DATE,
    cod_rastreio VARCHAR(50),
    created_at TIMESTAMP,
    FOREIGN KEY (cliente_id) REFERENCES cliente(cliente_id),
    FOREIGN KEY (endereco_entrega_id) REFERENCES endereco_cliente(id)
);

CREATE TABLE pedido_item (
    id UUID PRIMARY KEY,
    pedido_id UUID,
    produto_id UUID,
    vendedor_id UUID,
    quantidade INTEGER,
    preco_unitario NUMERIC(10,2),
    subtotal NUMERIC(10,2),
    created_at TIMESTAMP,
    FOREIGN KEY (pedido_id) REFERENCES pedido(id),
    FOREIGN KEY (produto_id) REFERENCES produto(id),
    FOREIGN KEY (vendedor_id) REFERENCES vendedor(id)
);