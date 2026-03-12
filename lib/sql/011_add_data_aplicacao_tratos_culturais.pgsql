-- NOTA: Operações idempotentes. Pode executar mais de uma vez sem risco.

ALTER TABLE tratos_culturais
  ADD COLUMN IF NOT EXISTS data_aplicacao DATE;
