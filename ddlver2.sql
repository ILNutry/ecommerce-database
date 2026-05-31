CREATE TABLE ecommerce.cliente (
    cliente_id CHAR(36) PRIMARY KEY,
    tipo_cliente ENUM('PF','PJ') NOT NULL,
    email VARCHAR(255)
);

CREATE TABLE endereco_cliente (
    id CHAR(36) PRIMARY KEY,
    cliente_id CHAR(36) NOT NULL,

    cep VARCHAR(10),
    logradouro VARCHAR(255),
    numero VARCHAR(20),
    complemento VARCHAR(100),
    bairro VARCHAR(100),
    cidade VARCHAR(100),
    uf CHAR(2),

    FOREIGN KEY (cliente_id)
    REFERENCES cliente(cliente_id)
);

CREATE TABLE forma_pagamento (
    id CHAR(36) PRIMARY KEY,
    descricao VARCHAR(50) NOT NULL
);   

CREATE TABLE cliente_pagamento (
    id CHAR(36) PRIMARY KEY,

    cliente_id CHAR(36) NOT NULL,
    forma_pagamento_id CHAR(36) NOT NULL,

    FOREIGN KEY (cliente_id)
        REFERENCES cliente(cliente_id),

    FOREIGN KEY (forma_pagamento_id)
        REFERENCES forma_pagamento(id)
);

CREATE TABLE fornecedor (
    id CHAR(36) PRIMARY KEY,

    nome VARCHAR(255) NOT NULL,
    cnpj VARCHAR(18) UNIQUE,
    email VARCHAR(255)
);

CREATE TABLE vendedor (
    id CHAR(36) PRIMARY KEY,

    nome VARCHAR(255) NOT NULL,
    cnpj VARCHAR(18),
    email VARCHAR(255)
);

CREATE TABLE produto (
    id CHAR(36) PRIMARY KEY,

    fornecedor_id CHAR(36),

    sku VARCHAR(50) UNIQUE,
    nome VARCHAR(255),
    descricao TEXT,

    preco_base DECIMAL(10,2) NOT NULL,

    ativo BOOLEAN DEFAULT TRUE,

    FOREIGN KEY (fornecedor_id)
    REFERENCES fornecedor(id)
);

CREATE TABLE vendedor_produto (
    id CHAR(36) PRIMARY KEY,

    vendedor_id CHAR(36),
    produto_id CHAR(36),

    preco_vendedor DECIMAL(10,2),

    FOREIGN KEY (vendedor_id)
    REFERENCES vendedor(id),

    FOREIGN KEY (produto_id)
    REFERENCES produto(id)
);

CREATE TABLE deposito (
    id CHAR(36) PRIMARY KEY,

    nome VARCHAR(255),
    cidade VARCHAR(100),
    uf CHAR(2)
);

CREATE TABLE estoque (
    id CHAR(36) PRIMARY KEY,

    produto_id CHAR(36),
    deposito_id CHAR(36),

    quantidade INT NOT NULL,

    FOREIGN KEY (produto_id)
    REFERENCES produto(id),

    FOREIGN KEY (deposito_id)
    REFERENCES deposito(id)
);

CREATE TABLE pedido (
    id CHAR(36) PRIMARY KEY,

    cliente_id CHAR(36) NOT NULL,
    endereco_entrega_id CHAR(36),

    frete_valor DECIMAL(10,2),
    total_itens DECIMAL(10,2),
    total_pedido DECIMAL(10,2),

    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY (cliente_id)
    REFERENCES cliente(cliente_id),

    FOREIGN KEY (endereco_entrega_id)
    REFERENCES endereco_cliente(id)
);

CREATE TABLE pedido_item (
    id CHAR(36) PRIMARY KEY,

    pedido_id CHAR(36),
    produto_id CHAR(36),
    vendedor_id CHAR(36),

    quantidade INT,
    preco_unitario DECIMAL(10,2),
    subtotal DECIMAL(10,2),

    FOREIGN KEY (pedido_id)
    REFERENCES pedido(id),

    FOREIGN KEY (produto_id)
    REFERENCES produto(id),

    FOREIGN KEY (vendedor_id)
    REFERENCES vendedor(id)
);

CREATE TABLE entrega (
    id CHAR(36) PRIMARY KEY,

    pedido_id CHAR(36),

    status_entrega ENUM(
        'Processando',
        'Separacao',
        'Em Transito',
        'Entregue',
        'Cancelado'
    ),

    codigo_rastreio VARCHAR(100),

    FOREIGN KEY (pedido_id)
    REFERENCES pedido(id)
);

INSERT INTO cliente VALUES
('CLI001','PF','joao@email.com',NOW()),
('CLI002','PF','maria@email.com',NOW()),
('CLI003','PJ','empresa@email.com',NOW());

INSERT INTO cliente_pf VALUES
('CLI001','João Silva','111.111.111-11','1990-01-10'),
('CLI002','Maria Souza','222.222.222-22','1985-08-15');

INSERT INTO forma_pagamento VALUES
('FP001','Cartão de Crédito'),
('FP002','PIX'),
('FP003','Boleto');

CREATE TABLE cliente_pj (
    cliente_id CHAR(36) PRIMARY KEY,
    razao_social VARCHAR(255) NOT NULL,
    nome_fantasia VARCHAR(255),
    cnpj VARCHAR(18) UNIQUE NOT NULL,

    FOREIGN KEY (cliente_id)
    REFERENCES cliente(cliente_id)
);
INSERT INTO cliente_pj VALUES
('CLI003','Empresa ABC LTDA','ABC','11.111.111/0001-11');

INSERT INTO endereco_cliente VALUES
('END001','CLI001','80000-000','Rua das Flores','100','','Centro','Curitiba','PR'),

('END002','CLI002','81000-000','Av. Brasil','250','','Boqueirão','Curitiba','PR'),

('END003','CLI003','82000-000','Rua Industrial','500','Sala 1','CIC','Curitiba','PR');

INSERT INTO cliente_pagamento VALUES
('CP001','CLI001','FP001'),
('CP002','CLI001','FP002'),
('CP003','CLI002','FP002'),
('CP004','CLI003','FP003');

INSERT INTO fornecedor VALUES
('FOR001','Fornecedor Tech','11.111.111/0001-99','fornecedor@email.com');

INSERT INTO fornecedor
(id, nome, cnpj, email)
VALUES
('FOR002', 'Logitech Brasil', '22.222.222/0001-22', 'contato@logitech.com'),

('FOR003', 'Samsung Brasil', '33.333.333/0001-33', 'contato@samsung.com'),

('FOR004', 'LG Brasil', '44.444.444/0001-44', 'contato@lg.com'),

('FOR005', 'Kingston Brasil', '55.555.555/0001-55', 'contato@kingston.com');

INSERT INTO produto VALUES
('PRO001','FOR001','SKU001','Notebook Dell','Notebook i7',3500.00,1),
('PRO002','FOR001','SKU002','Mouse Logitech','Mouse sem fio',120.00,1);

INSERT INTO produto (id, fornecedor_id, sku, nome, descricao, preco_base, ativo)
values ('PRO003','FOR002','SKU003','Teclado Logitech K120','Teclado USB',90.00,1);


INSERT INTO vendedor VALUES
('VEN001','Marketplace Sul','22.222.222/0001-22','vendedor@email.com');

INSERT INTO deposito VALUES
('DEP001','CD Curitiba','Curitiba','PR');

INSERT INTO vendedor_produto VALUES
('VP001','VEN001','PRO001',3700.00);

INSERT INTO estoque VALUES
('EST001','PRO001','DEP001',20),
('EST002','PRO002','DEP001',100);

INSERT INTO entrega
(id, pedido_id, status_entrega, codigo_rastreio)
VALUES
('ENT001','PED001','Entregue','BR123456789'),
('ENT002','PED002','Em Transito','BR987654321'),
('ENT003','PED003','Processando','BR111222333');

INSERT INTO pedido VALUES
(
'PED001',
'CLI001',
'END001',
25.00,
3820.00,
3845.00,
NOW()
),

(
'PED002',
'CLI002',
'END002',
20.00,
260.00,
280.00,
NOW()
),

(
'PED003',
'CLI003',
'END003',
35.00,
3745.00,
3780.00,
NOW()
);

INSERT INTO pedido_item VALUES
(
'PI001',
'PED001',
'PRO001',
'VEN001',
1,
3700.00,
3700.00
),

(
'PI002',
'PED001',
'PRO002',
'VEN001',
1,
120.00,
120.00
),

(
'PI003',
'PED002',
'PRO002',
'VEN001',
2,
130.00,
260.00
),

(
'PI004',
'PED003',
'PRO001',
'VEN002',
1,
3650.00,
3650.00
),

(
'PI005',
'PED003',
'PRO003',
'VEN002',
1,
95.00,
95.00
);


SELECT
    c.email,
    COUNT(p.id) AS total_pedidos
FROM cliente c
LEFT JOIN pedido p
ON c.cliente_id = p.cliente_id
GROUP BY c.email;

SELECT
    f.nome AS fornecedor,
    p.nome AS produto
FROM fornecedor f
INNER JOIN produto p
ON f.id = p.fornecedor_id;

SELECT
    f.nome AS fornecedor,
    p.nome AS produto,
    d.nome AS deposito,
    e.quantidade
FROM fornecedor f
JOIN produto p
ON f.id = p.fornecedor_id
JOIN estoque e
ON p.id = e.produto_id
JOIN deposito d
ON d.id = e.deposito_id;

SELECT
    v.nome,
    v.cnpj
FROM vendedor v
JOIN fornecedor f
ON v.cnpj = f.cnpj;

SELECT
    v.nome,
    SUM(pi.subtotal) AS faturamento
FROM vendedor v
JOIN pedido_item pi
ON v.id = pi.vendedor_id
GROUP BY v.nome
ORDER BY faturamento DESC;

SELECT
    ROUND(AVG(total_pedido),2) AS ticket_medio
FROM pedido;

SELECT
    p.nome,
    SUM(pi.quantidade) AS quantidade_vendida
FROM produto p
JOIN pedido_item pi
ON p.id = pi.produto_id
GROUP BY p.nome
ORDER BY quantidade_vendida DESC;

SELECT
    p.id AS pedido,
    COALESCE(cpf.nome, cpj.razao_social) AS cliente,
    p.total_pedido,
    e.status_entrega,
    e.codigo_rastreio
FROM pedido p
INNER JOIN cliente c
    ON p.cliente_id = c.cliente_id
LEFT JOIN cliente_pf cpf
    ON c.cliente_id = cpf.cliente_id
LEFT JOIN cliente_pj cpj
    ON c.cliente_id = cpj.cliente_id
LEFT JOIN entrega e
    ON p.id = e.pedido_id;
    
SELECT
    f.nome AS fornecedor,
    p.nome AS produto,
    d.nome AS deposito,
    e.quantidade
FROM fornecedor f
INNER JOIN produto p
    ON f.id = p.fornecedor_id
INNER JOIN estoque e
    ON p.id = e.produto_id
INNER JOIN deposito d
    ON e.deposito_id = d.id
ORDER BY fornecedor, produto;

SELECT
    COALESCE(cpf.nome, cpj.razao_social) AS cliente,
    ped.id AS pedido,
    prod.nome AS produto,
    pi.quantidade,
    pi.subtotal
FROM cliente c
INNER JOIN pedido ped
    ON c.cliente_id = ped.cliente_id
INNER JOIN pedido_item pi
    ON ped.id = pi.pedido_id
INNER JOIN produto prod
    ON pi.produto_id = prod.id
LEFT JOIN cliente_pf cpf
    ON c.cliente_id = cpf.cliente_id
LEFT JOIN cliente_pj cpj
    ON c.cliente_id = cpj.cliente_id
ORDER BY cliente;

SELECT
    COALESCE(cpf.nome, cpj.razao_social) AS cliente,
    fp.descricao AS forma_pagamento
FROM cliente c
INNER JOIN cliente_pagamento cp
    ON c.cliente_id = cp.cliente_id
INNER JOIN forma_pagamento fp
    ON cp.forma_pagamento_id = fp.id
LEFT JOIN cliente_pf cpf
    ON c.cliente_id = cpf.cliente_id
LEFT JOIN cliente_pj cpj
    ON c.cliente_id = cpj.cliente_id;
    
    SELECT
    p.nome,
    SUM(pi.quantidade) AS quantidade_vendida,
    SUM(pi.subtotal) AS receita
FROM produto p
INNER JOIN pedido_item pi
    ON p.id = pi.produto_id
GROUP BY p.nome
ORDER BY quantidade_vendida DESC;

SELECT
    COALESCE(cpf.nome, cpj.razao_social) AS cliente,
    SUM(p.total_pedido) AS total_gasto
FROM cliente c
INNER JOIN pedido p
    ON c.cliente_id = p.cliente_id
LEFT JOIN cliente_pf cpf
    ON c.cliente_id = cpf.cliente_id
LEFT JOIN cliente_pj cpj
    ON c.cliente_id = cpj.cliente_id
GROUP BY cliente
HAVING total_gasto > 1000
ORDER BY total_gasto DESC;

SELECT
    ped.id AS pedido,
    COALESCE(cpf.nome, cpj.razao_social) AS cliente,
    prod.nome AS produto,
    forn.nome AS fornecedor,
    vend.nome AS vendedor,
    pi.quantidade,
    pi.subtotal,
    ent.status_entrega
FROM pedido ped
INNER JOIN cliente c
    ON ped.cliente_id = c.cliente_id
INNER JOIN pedido_item pi
    ON ped.id = pi.pedido_id
INNER JOIN produto prod
    ON pi.produto_id = prod.id
INNER JOIN fornecedor forn
    ON prod.fornecedor_id = forn.id
INNER JOIN vendedor vend
    ON pi.vendedor_id = vend.id
LEFT JOIN entrega ent
    ON ped.id = ent.pedido_id
LEFT JOIN cliente_pf cpf
    ON c.cliente_id = cpf.cliente_id
LEFT JOIN cliente_pj cpj
    ON c.cliente_id = cpj.cliente_id;