-- Fornecedor dos produtos.
CREATE TABLE [vendendor_terceiro] (
	[id] uniqueidentifier NOT NULL,
	[nome] nvarchar(200) NOT NULL,
	[cnpj] nvarchar(18) NOT NULL UNIQUE,
	[email] nvarchar(200),
	[telefone] nvarchar(30),
	[created_at] rowversion NOT NULL DEFAULT 'now()',
	PRIMARY KEY ([id])
);
-- Cliente que se cadastra no site.
CREATE TABLE [cliente] (
	[cliente_id] uniqueidentifier NOT NULL,
	[cpf] nvarchar(14) UNIQUE,
	[cnpj] nvarchar(18) UNIQUE,
	[nome] nvarchar(200) NOT NULL,
	[email] nvarchar(200) NOT NULL UNIQUE,
	[created_at] rowversion NOT NULL DEFAULT 'now()',
	[forma_pagamento] nvarchar(max) NOT NULL UNIQUE,
	PRIMARY KEY ([cliente_id]),
	CONSTRAINT [ck_cliente_cpf_ou_cnpj] CHECK (cpf is not null and cnpj is null) or (cpf is null and cnpj is not null),
	CONSTRAINT [ck_cliente_forma_pagamento_validas] CHECK forma_pagamento in ('BOLETO','PIX','CARTAO')
);
-- Endereços do cliente (usado para cálculo de frete no pedido).
CREATE TABLE [endereco_cliente] (
	[id] uniqueidentifier NOT NULL,
	[cliente_id] uniqueidentifier NOT NULL,
	[apelido] nvarchar(100),
	[cep] nvarchar(10) NOT NULL,
	[logradouro] nvarchar(200) NOT NULL,
	[numero] nvarchar(20) NOT NULL,
	[complemento] nvarchar(100),
	[bairro] nvarchar(120) NOT NULL,
	[cidade] nvarchar(120) NOT NULL,
	[uf] nvarchar(2) NOT NULL,
	[created_at] rowversion NOT NULL DEFAULT 'now()',
	PRIMARY KEY ([id])
);
-- Produtos vendidos na plataforma.
CREATE TABLE [produto] (
	[id] uniqueidentifier NOT NULL,
	[sku] nvarchar(80) UNIQUE,
	[nome] nvarchar(200) NOT NULL,
	[descricao] nvarchar(max),
	[preco_base] int NOT NULL,
	[ativo] bit NOT NULL DEFAULT true,
	[created_at] rowversion NOT NULL DEFAULT 'now()',
	PRIMARY KEY ([id])
);
-- Vendedores terceiros que podem vender produtos na plataforma.
CREATE TABLE [vendedor] (
	[id] uniqueidentifier NOT NULL,
	[nome] nvarchar(200) NOT NULL,
	[cnpj] nvarchar(18) UNIQUE,
	[email] nvarchar(200) NOT NULL UNIQUE,
	[created_at] rowversion NOT NULL DEFAULT 'now()',
	PRIMARY KEY ([id])
);
-- Junção para permitir que vendedores distintos vendam o mesmo produto.
CREATE TABLE [vendedor_produto] (
	[id] uniqueidentifier NOT NULL,
	[vendedor_id] uniqueidentifier NOT NULL,
	[produto_id] uniqueidentifier NOT NULL,
	[preco_vendedor] decimal(12) NOT NULL,
	[ativo] bit NOT NULL DEFAULT true,
	[created_at] rowversion NOT NULL DEFAULT 'now()',
	PRIMARY KEY ([id]),
	CONSTRAINT [uq_vendedor_produto] UNIQUE (vendedor_id, produto_id)
);
-- Depósitos/locais onde o estoque é mantido (opcional, mas útil).
CREATE TABLE [deposito] (
	[id] uniqueidentifier NOT NULL,
	[nome] nvarchar(200) NOT NULL,
	[cidade] nvarchar(120),
	[uf] nvarchar(2),
	[created_at] rowversion NOT NULL DEFAULT 'now()',
	PRIMARY KEY ([id])
);
-- Controle de quantidade em estoque por produto e depósito.
CREATE TABLE [Produto_Has_estoque] (
	[produto_id] uniqueidentifier NOT NULL,
	[deposito_id] uniqueidentifier,
	[id] uniqueidentifier NOT NULL,
	[quantidade] int NOT NULL DEFAULT 0,
	[atualizado_em] rowversion NOT NULL DEFAULT 'now()',
	PRIMARY KEY ([id]),
	CONSTRAINT [uq_estoque_produto_deposito] UNIQUE (produto_id, deposito_id),
	CONSTRAINT [ck_estoque_quantidade_nao_negativa] CHECK (quantidade >= 0)
);
-- Pedidos criados por cliente com endereço, frete e status de entrega.
CREATE TABLE [pedido] (
	[id] uniqueidentifier NOT NULL,
	[cliente_id] uniqueidentifier NOT NULL,
	[endereco_entrega_id] uniqueidentifier NOT NULL,
	[status_entrega] nvarchar(50) NOT NULL DEFAULT '''PENDENTE''',
	[cancelado_em] rowversion,
	[frete_valor] decimal(12) NOT NULL DEFAULT 0,
	[total_itens] decimal(12) NOT NULL DEFAULT 0,
	[total_pedido] decimal(12) NOT NULL DEFAULT 0,
	[devolucao_ate] date,
	[created_at] rowversion NOT NULL DEFAULT 'now()',
	[Cod_rastr] nvarchar(16) NOT NULL,
	PRIMARY KEY ([id])
);
-- Itens que compõem o pedido (1..N produtos por pedido).
CREATE TABLE [pedido_item] (
	[id] uniqueidentifier NOT NULL,
	[pedido_id] uniqueidentifier NOT NULL,
	[produto_id] uniqueidentifier NOT NULL,
	[vendedor_id] uniqueidentifier,
	[quantidade] int NOT NULL DEFAULT 1,
	[preco_unitario] decimal(12) NOT NULL,
	[subtotal] decimal(12) NOT NULL,
	[created_at] rowversion NOT NULL DEFAULT 'now()',
	PRIMARY KEY ([id]),
	CONSTRAINT [ck_pedido_item_quantidade_min_1] CHECK (quantidade >= 1)
);
ALTER TABLE [endereco_cliente] ADD CONSTRAINT [endereco_cliente_fk1] FOREIGN KEY ([cliente_id]) REFERENCES [cliente]([cliente_id]);
ALTER TABLE [vendedor_produto] ADD CONSTRAINT [vendedor_produto_fk1] FOREIGN KEY ([vendedor_id]) REFERENCES [vendedor]([id]);
ALTER TABLE [vendedor_produto] ADD CONSTRAINT [vendedor_produto_fk2] FOREIGN KEY ([produto_id]) REFERENCES [produto]([id]);
ALTER TABLE [Produto_Has_estoque] ADD CONSTRAINT [Produto_Has_estoque_fk0] FOREIGN KEY ([produto_id]) REFERENCES [produto]([id]);
ALTER TABLE [Produto_Has_estoque] ADD CONSTRAINT [Produto_Has_estoque_fk1] FOREIGN KEY ([deposito_id]) REFERENCES [deposito]([id]);
ALTER TABLE [pedido] ADD CONSTRAINT [pedido_fk1] FOREIGN KEY ([cliente_id]) REFERENCES [cliente]([cliente_id]);
ALTER TABLE [pedido] ADD CONSTRAINT [pedido_fk2] FOREIGN KEY ([endereco_entrega_id]) REFERENCES [endereco_cliente]([id]);
ALTER TABLE [pedido] ADD CONSTRAINT [pedido_fk10] FOREIGN KEY ([Cod_rastr]) REFERENCES [pedido_item]([id]);
ALTER TABLE [pedido_item] ADD CONSTRAINT [pedido_item_fk1] FOREIGN KEY ([pedido_id]) REFERENCES [pedido]([id]);
ALTER TABLE [pedido_item] ADD CONSTRAINT [pedido_item_fk2] FOREIGN KEY ([produto_id]) REFERENCES [produto]([id]);
ALTER TABLE [pedido_item] ADD CONSTRAINT [pedido_item_fk3] FOREIGN KEY ([vendedor_id]) REFERENCES [vendedor]([id]);
CREATE INDEX [idx_endereco_cliente] ON [endereco_cliente] ([cliente_id]);
CREATE INDEX [idx_produto_fornecedor] ON [produto] ([fornecedor_id]);
CREATE INDEX [idx_vendedor_produto_vendedor] ON [vendedor_produto] ([vendedor_id]);
CREATE INDEX [idx_vendedor_produto_produto] ON [vendedor_produto] ([produto_id]);
CREATE INDEX [idx_estoque_produto] ON [Produto_Has_estoque] ([produto_id]);
CREATE INDEX [idx_estoque_deposito] ON [Produto_Has_estoque] ([deposito_id]);
CREATE INDEX [idx_pedido_cliente] ON [pedido] ([cliente_id]);
CREATE INDEX [idx_pedido_status] ON [pedido] ([status_entrega]);
CREATE INDEX [idx_pedido_item_pedido] ON [pedido_item] ([pedido_id]);
CREATE INDEX [idx_pedido_item_produto] ON [pedido_item] ([produto_id]);
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Fornecedor dos produtos.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendendor_terceiro';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador do fornecedor.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendendor_terceiro', @level2type = N'COLUMN', @level2name = 'id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Nome/razão social.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendendor_terceiro', @level2type = N'COLUMN', @level2name = 'nome';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'CNPJ do fornecedor.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendendor_terceiro', @level2type = N'COLUMN', @level2name = 'cnpj';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Contato do fornecedor.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendendor_terceiro', @level2type = N'COLUMN', @level2name = 'email';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Contato do fornecedor.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendendor_terceiro', @level2type = N'COLUMN', @level2name = 'telefone';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Data de criação.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendendor_terceiro', @level2type = N'COLUMN', @level2name = 'created_at';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Cliente que se cadastra no site.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'cliente';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador do cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'cliente', @level2type = N'COLUMN', @level2name = 'cliente_id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'CPF do cliente (opcional, conforme narrativa).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'cliente', @level2type = N'COLUMN', @level2name = 'cpf';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'CNPJ do cliente (opcional, conforme narrativa).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'cliente', @level2type = N'COLUMN', @level2name = 'cnpj';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Nome do cliente.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'cliente', @level2type = N'COLUMN', @level2name = 'nome';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'E-mail para login/contato.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'cliente', @level2type = N'COLUMN', @level2name = 'email';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Data de criação.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'cliente', @level2type = N'COLUMN', @level2name = 'created_at';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'pagamento', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'cliente', @level2type = N'COLUMN', @level2name = 'forma_pagamento';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Endereços do cliente (usado para cálculo de frete no pedido).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'endereco_cliente';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador do endereço.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'endereco_cliente', @level2type = N'COLUMN', @level2name = 'id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Cliente dono do endereço.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'endereco_cliente', @level2type = N'COLUMN', @level2name = 'cliente_id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Ex.: Comercial, Residencial.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'endereco_cliente', @level2type = N'COLUMN', @level2name = 'apelido';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'CEP.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'endereco_cliente', @level2type = N'COLUMN', @level2name = 'cep';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Rua/avenida.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'endereco_cliente', @level2type = N'COLUMN', @level2name = 'logradouro';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Número.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'endereco_cliente', @level2type = N'COLUMN', @level2name = 'numero';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Complemento.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'endereco_cliente', @level2type = N'COLUMN', @level2name = 'complemento';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Bairro.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'endereco_cliente', @level2type = N'COLUMN', @level2name = 'bairro';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Cidade.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'endereco_cliente', @level2type = N'COLUMN', @level2name = 'cidade';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'UF.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'endereco_cliente', @level2type = N'COLUMN', @level2name = 'uf';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Data de criação.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'endereco_cliente', @level2type = N'COLUMN', @level2name = 'created_at';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Produtos vendidos na plataforma.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'produto';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador do produto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'produto', @level2type = N'COLUMN', @level2name = 'id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Fornecedor do produto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'produto';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'SKU (opcional).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'produto', @level2type = N'COLUMN', @level2name = 'sku';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Nome do produto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'produto', @level2type = N'COLUMN', @level2name = 'nome';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Descrição do produto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'produto', @level2type = N'COLUMN', @level2name = 'descricao';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Preço base (pode ser ajustado por vendedor).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'produto', @level2type = N'COLUMN', @level2name = 'preco_base';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Indica se o produto está ativo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'produto', @level2type = N'COLUMN', @level2name = 'ativo';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Data de criação.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'produto', @level2type = N'COLUMN', @level2name = 'created_at';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Vendedores terceiros que podem vender produtos na plataforma.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendedor';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador do vendedor.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendedor', @level2type = N'COLUMN', @level2name = 'id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Nome do vendedor.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendedor', @level2type = N'COLUMN', @level2name = 'nome';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'CNPJ do vendedor (se aplicável).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendedor', @level2type = N'COLUMN', @level2name = 'cnpj';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'E-mail do vendedor.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendedor', @level2type = N'COLUMN', @level2name = 'email';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Data de criação.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendedor', @level2type = N'COLUMN', @level2name = 'created_at';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Junção para permitir que vendedores distintos vendam o mesmo produto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendedor_produto';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador do vínculo.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendedor_produto', @level2type = N'COLUMN', @level2name = 'id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Vendedor.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendedor_produto', @level2type = N'COLUMN', @level2name = 'vendedor_id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Produto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendedor_produto', @level2type = N'COLUMN', @level2name = 'produto_id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Preço praticado por este vendedor para o produto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendedor_produto', @level2type = N'COLUMN', @level2name = 'preco_vendedor';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Se o vendedor está ofertando o produto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendedor_produto', @level2type = N'COLUMN', @level2name = 'ativo';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Data de criação.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'vendedor_produto', @level2type = N'COLUMN', @level2name = 'created_at';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Depósitos/locais onde o estoque é mantido (opcional, mas útil).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'deposito';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador do depósito.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'deposito', @level2type = N'COLUMN', @level2name = 'id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Nome do depósito.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'deposito', @level2type = N'COLUMN', @level2name = 'nome';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Cidade (opcional).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'deposito', @level2type = N'COLUMN', @level2name = 'cidade';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'UF (opcional).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'deposito', @level2type = N'COLUMN', @level2name = 'uf';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Data de criação.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'deposito', @level2type = N'COLUMN', @level2name = 'created_at';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Controle de quantidade em estoque por produto e depósito.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'Produto_Has_estoque';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Produto.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'Produto_Has_estoque', @level2type = N'COLUMN', @level2name = 'produto_id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Depósito (opcional).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'Produto_Has_estoque', @level2type = N'COLUMN', @level2name = 'deposito_id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador do registro de estoque.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'Produto_Has_estoque', @level2type = N'COLUMN', @level2name = 'id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Quantidade disponível.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'Produto_Has_estoque', @level2type = N'COLUMN', @level2name = 'quantidade';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Última atualização.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'Produto_Has_estoque', @level2type = N'COLUMN', @level2name = 'atualizado_em';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Pedidos criados por cliente com endereço, frete e status de entrega.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador do pedido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido', @level2type = N'COLUMN', @level2name = 'id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Cliente que fez o pedido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido', @level2type = N'COLUMN', @level2name = 'cliente_id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Endereço usado para entrega (para cálculo de frete).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido', @level2type = N'COLUMN', @level2name = 'endereco_entrega_id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Status de entrega (ex.: PENDENTE, ENVIADO, ENTREGUE, CANCELADO).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido', @level2type = N'COLUMN', @level2name = 'status_entrega';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Data de cancelamento (se aplicável).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido', @level2type = N'COLUMN', @level2name = 'cancelado_em';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Valor do frete calculado pelo endereço.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido', @level2type = N'COLUMN', @level2name = 'frete_valor';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Soma dos itens do pedido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido', @level2type = N'COLUMN', @level2name = 'total_itens';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Total do pedido (itens + frete).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido', @level2type = N'COLUMN', @level2name = 'total_pedido';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Data limite para devolução (período de carência).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido', @level2type = N'COLUMN', @level2name = 'devolucao_ate';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Data de criação.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido', @level2type = N'COLUMN', @level2name = 'created_at';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Código Rastreio', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido', @level2type = N'COLUMN', @level2name = 'Cod_rastr';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Itens que compõem o pedido (1..N produtos por pedido).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido_item';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Identificador do item.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido_item', @level2type = N'COLUMN', @level2name = 'id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Pedido ao qual o item pertence.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido_item', @level2type = N'COLUMN', @level2name = 'pedido_id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Produto do item.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido_item', @level2type = N'COLUMN', @level2name = 'produto_id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Vendedor responsável pelo item (se aplicável).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido_item', @level2type = N'COLUMN', @level2name = 'vendedor_id';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Quantidade do produto no pedido.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido_item', @level2type = N'COLUMN', @level2name = 'quantidade';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Preço unitário no momento da compra.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido_item', @level2type = N'COLUMN', @level2name = 'preco_unitario';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Subtotal do item (quantidade * preço unitário).', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido_item', @level2type = N'COLUMN', @level2name = 'subtotal';
EXEC sys.sp_addextendedproperty @name = N'MS_Description', @value = 'Data de criação.', @level0type = N'SCHEMA', @level0name = N'dbo', @level1type = N'TABLE', @level1name = 'pedido_item', @level2type = N'COLUMN', @level2name = 'created_at';