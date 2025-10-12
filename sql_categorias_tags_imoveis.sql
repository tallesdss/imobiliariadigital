-- Script SQL para adicionar campos de categorias e tags na tabela de imóveis
-- Este script deve ser executado no banco de dados Supabase

-- 1. Adicionar campo categoria
ALTER TABLE properties 
ADD COLUMN IF NOT EXISTS categoria VARCHAR(20);

-- 2. Adicionar campo tags (array de strings)
ALTER TABLE properties 
ADD COLUMN IF NOT EXISTS tags TEXT[] DEFAULT '{}';

-- 3. Adicionar comentários para documentação
COMMENT ON COLUMN properties.categoria IS 'Categoria do imóvel: residencial, comercial, industrial, rural, luxo, investimento, ferias, estudante';
COMMENT ON COLUMN properties.tags IS 'Array de tags que descrevem características especiais do imóvel';

-- 4. Criar índices para melhorar performance das consultas por categoria e tags
CREATE INDEX IF NOT EXISTS idx_properties_categoria ON properties(categoria);
CREATE INDEX IF NOT EXISTS idx_properties_tags ON properties USING GIN(tags);

-- 5. Atualizar dados existentes (opcional - migração de dados antigos)
-- Migrar tags antigas (destaque e lançamento) para o novo sistema
UPDATE properties 
SET tags = CASE 
    WHEN destaque = true AND lancamento = true THEN ARRAY['destaque', 'lancamento']
    WHEN destaque = true THEN ARRAY['destaque']
    WHEN lancamento = true THEN ARRAY['lancamento']
    ELSE ARRAY[]::TEXT[]
END
WHERE tags IS NULL OR array_length(tags, 1) IS NULL;

-- 6. Definir categoria padrão baseada no tipo de imóvel
UPDATE properties 
SET categoria = CASE 
    WHEN tipo_imovel IN ('casa', 'apartamento') THEN 'residencial'
    WHEN tipo_imovel = 'comercial' THEN 'comercial'
    WHEN tipo_imovel = 'terreno' THEN 'rural'
    ELSE 'residencial'
END
WHERE categoria IS NULL;

-- 7. Adicionar constraints para validar valores
ALTER TABLE properties 
ADD CONSTRAINT check_categoria_valida 
CHECK (categoria IS NULL OR categoria IN (
    'residencial', 'comercial', 'industrial', 'rural', 
    'luxo', 'investimento', 'ferias', 'estudante'
));

-- 8. Criar função para buscar imóveis por tags
CREATE OR REPLACE FUNCTION buscar_imoveis_por_tags(tags_busca TEXT[])
RETURNS TABLE (
    id UUID,
    titulo VARCHAR,
    preco DECIMAL,
    cidade VARCHAR,
    tags TEXT[]
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.titulo,
        p.preco,
        p.cidade,
        p.tags
    FROM properties p
    WHERE p.status = 'ativo'
    AND p.tags && tags_busca; -- Operador && verifica se há interseção entre arrays
END;
$$ LANGUAGE plpgsql;

-- 9. Criar função para buscar imóveis por categoria
CREATE OR REPLACE FUNCTION buscar_imoveis_por_categoria(categoria_busca VARCHAR)
RETURNS TABLE (
    id UUID,
    titulo VARCHAR,
    preco DECIMAL,
    cidade VARCHAR,
    categoria VARCHAR
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        p.id,
        p.titulo,
        p.preco,
        p.cidade,
        p.categoria
    FROM properties p
    WHERE p.status = 'ativo'
    AND p.categoria = categoria_busca;
END;
$$ LANGUAGE plpgsql;

-- 10. Exemplo de uso das funções:
-- SELECT * FROM buscar_imoveis_por_tags(ARRAY['destaque', 'com_piscina']);
-- SELECT * FROM buscar_imoveis_por_categoria('residencial');

-- 11. Adicionar comentários finais
COMMENT ON FUNCTION buscar_imoveis_por_tags(TEXT[]) IS 'Busca imóveis que possuem pelo menos uma das tags especificadas';
COMMENT ON FUNCTION buscar_imoveis_por_categoria(VARCHAR) IS 'Busca imóveis por categoria específica';
