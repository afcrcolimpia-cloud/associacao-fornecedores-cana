-- NOTA: Operações idempotentes. Pode executar mais de uma vez sem risco.

ALTER TABLE tratos_culturais
  ADD COLUMN IF NOT EXISTS campos_extras JSONB;
