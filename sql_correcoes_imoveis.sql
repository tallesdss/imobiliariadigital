-- Script SQL para correções na tabela de imóveis
-- Adiciona campos faltantes identificados na análise

-- 1. Adicionar campo tipo_transacao (faltante no banco)
ALTER TABLE properties 
ADD COLUMN IF NOT EXISTS tipo_transacao VARCHAR(20);

-- 2. Adicionar campo bairro (faltante no banco)
ALTER TABLE properties 
ADD COLUMN IF NOT EXISTS bairro VARCHAR(100);

-- 3. Atualizar a estrutura da tabela properties para incluir todos os campos necessários
-- (Caso a tabela não exista, criar com a estrutura completa)

CREATE TABLE IF NOT EXISTS properties (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    titulo VARCHAR(255) NOT NULL,
    descricao TEXT,
    preco DECIMAL(15,2) NOT NULL,
    tipo_imovel VARCHAR(20) NOT NULL CHECK (tipo_imovel IN ('casa', 'apartamento', 'comercial', 'terreno')),
    status VARCHAR(20) NOT NULL DEFAULT 'ativo' CHECK (status IN ('ativo', 'vendido', 'arquivado', 'suspenso')),
    tipo_transacao VARCHAR(20) CHECK (tipo_transacao IN ('venda', 'aluguel', 'temporada')),
    endereco VARCHAR(500) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    estado VARCHAR(2) NOT NULL,
    cep VARCHAR(10),
    bairro VARCHAR(100),
    fotos JSONB DEFAULT '[]'::jsonb,
    videos JSONB DEFAULT '[]'::jsonb,
    atributos JSONB DEFAULT '{}'::jsonb,
    corretor_id UUID NOT NULL,
    nome_corretor VARCHAR(255) NOT NULL,
    telefone_corretor VARCHAR(20),
    contato_admin VARCHAR(255),
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    data_atualizacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    destaque BOOLEAN DEFAULT FALSE,
    lancamento BOOLEAN DEFAULT FALSE,
    
    -- Índices para melhor performance
    CONSTRAINT fk_properties_corretor FOREIGN KEY (corretor_id) REFERENCES realtors(id)
);

-- 4. Criar índices para melhorar performance das consultas
CREATE INDEX IF NOT EXISTS idx_properties_status ON properties(status);
CREATE INDEX IF NOT EXISTS idx_properties_tipo_imovel ON properties(tipo_imovel);
CREATE INDEX IF NOT EXISTS idx_properties_tipo_transacao ON properties(tipo_transacao);
CREATE INDEX IF NOT EXISTS idx_properties_cidade ON properties(cidade);
CREATE INDEX IF NOT EXISTS idx_properties_bairro ON properties(bairro);
CREATE INDEX IF NOT EXISTS idx_properties_preco ON properties(preco);
CREATE INDEX IF NOT EXISTS idx_properties_destaque ON properties(destaque);
CREATE INDEX IF NOT EXISTS idx_properties_lancamento ON properties(lancamento);
CREATE INDEX IF NOT EXISTS idx_properties_data_criacao ON properties(data_criacao);
CREATE INDEX IF NOT EXISTS idx_properties_corretor_id ON properties(corretor_id);

-- 5. Criar índices GIN para campos JSONB (atributos)
CREATE INDEX IF NOT EXISTS idx_properties_atributos_gin ON properties USING GIN (atributos);

-- 6. Atualizar trigger para data_atualizacao
CREATE OR REPLACE FUNCTION update_properties_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.data_atualizacao = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER IF NOT EXISTS trigger_update_properties_updated_at
    BEFORE UPDATE ON properties
    FOR EACH ROW
    EXECUTE FUNCTION update_properties_updated_at();

-- 7. Comentários para documentação
COMMENT ON TABLE properties IS 'Tabela de imóveis com todas as informações necessárias para o sistema';
COMMENT ON COLUMN properties.tipo_transacao IS 'Tipo de transação: venda, aluguel ou temporada';
COMMENT ON COLUMN properties.bairro IS 'Bairro do imóvel';
COMMENT ON COLUMN properties.atributos IS 'JSON com características específicas: quartos, banheiros, área, vagas, condomínio, IPTU, etc.';
COMMENT ON COLUMN properties.fotos IS 'Array JSON com URLs das fotos do imóvel';
COMMENT ON COLUMN properties.videos IS 'Array JSON com URLs dos vídeos do imóvel';

-- 8. Exemplo de estrutura do campo atributos
/*
Estrutura esperada do campo atributos:
{
  "bedrooms": 3,
  "bathrooms": 2,
  "area": 120.5,
  "parkingSpaces": 2,
  "condominium": 500.0,
  "iptu": 200.0,
  "hasGarage": true,
  "acceptsProposal": false,
  "hasFinancing": true,
  "furnished": false,
  "petFriendly": true,
  "hasSecurity": true,
  "hasSwimmingPool": false,
  "hasGym": true
}
*/

-- 9. Atualizar tabela de filtros para incluir novos campos
ALTER TABLE property_filters 
ADD COLUMN IF NOT EXISTS mobiliado BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS aceita_pets BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS tem_seguranca BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS tem_piscina BOOLEAN DEFAULT FALSE,
ADD COLUMN IF NOT EXISTS tem_academia BOOLEAN DEFAULT FALSE;

-- 10. Verificar se a tabela realtors existe (necessária para foreign key)
CREATE TABLE IF NOT EXISTS realtors (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    foto VARCHAR(500),
    creci VARCHAR(20) UNIQUE,
    biografia TEXT,
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ativo BOOLEAN DEFAULT TRUE,
    total_imoveis INTEGER DEFAULT 0,
    imoveis_vendidos INTEGER DEFAULT 0
);

-- 11. Verificar se a tabela users existe (necessária para foreign keys)
CREATE TABLE IF NOT EXISTS users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    nome VARCHAR(255) NOT NULL,
    email VARCHAR(255) UNIQUE NOT NULL,
    telefone VARCHAR(20),
    foto VARCHAR(500),
    tipo_usuario VARCHAR(20) NOT NULL CHECK (tipo_usuario IN ('comprador', 'corretor', 'administrador')),
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    ativo BOOLEAN DEFAULT TRUE
);

-- 12. Verificar se a tabela property_filters existe
CREATE TABLE IF NOT EXISTS property_filters (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    usuario_id UUID NOT NULL,
    nome_filtro VARCHAR(255) NOT NULL,
    preco_minimo DECIMAL(15,2),
    preco_maximo DECIMAL(15,2),
    tipo_transacao VARCHAR(20),
    condominio_maximo DECIMAL(15,2),
    iptu_maximo DECIMAL(15,2),
    apenas_com_preco BOOLEAN DEFAULT FALSE,
    aceita_proposta BOOLEAN DEFAULT FALSE,
    tem_financiamento BOOLEAN DEFAULT FALSE,
    faixas_preco JSONB DEFAULT '[]'::jsonb,
    mobiliado BOOLEAN DEFAULT FALSE,
    aceita_pets BOOLEAN DEFAULT FALSE,
    tem_seguranca BOOLEAN DEFAULT FALSE,
    tem_piscina BOOLEAN DEFAULT FALSE,
    tem_academia BOOLEAN DEFAULT FALSE,
    data_criacao TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    
    CONSTRAINT fk_property_filters_usuario FOREIGN KEY (usuario_id) REFERENCES users(id)
);

-- 13. Criar índices para property_filters
CREATE INDEX IF NOT EXISTS idx_property_filters_usuario_id ON property_filters(usuario_id);
CREATE INDEX IF NOT EXISTS idx_property_filters_tipo_transacao ON property_filters(tipo_transacao);

-- 14. Comentários para property_filters
COMMENT ON TABLE property_filters IS 'Filtros salvos pelos usuários para busca de imóveis';
COMMENT ON COLUMN property_filters.mobiliado IS 'Filtrar apenas imóveis mobiliados';
COMMENT ON COLUMN property_filters.aceita_pets IS 'Filtrar apenas imóveis que aceitam pets';
COMMENT ON COLUMN property_filters.tem_seguranca IS 'Filtrar apenas imóveis com segurança 24h';
COMMENT ON COLUMN property_filters.tem_piscina IS 'Filtrar apenas imóveis com piscina';
COMMENT ON COLUMN property_filters.tem_academia IS 'Filtrar apenas imóveis com academia';

-- 15. Verificar se todas as tabelas foram criadas corretamente
SELECT 
    table_name,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns 
WHERE table_name IN ('properties', 'realtors', 'users', 'property_filters')
ORDER BY table_name, ordinal_position;

-- 16. Verificar se os índices foram criados
SELECT 
    indexname,
    tablename,
    indexdef
FROM pg_indexes 
WHERE tablename IN ('properties', 'realtors', 'users', 'property_filters')
ORDER BY tablename, indexname;
