#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
  WITH raw_json AS (
    SELECT pg_read_file('/seed/spares_seed_data.json')::jsonb AS data
  )
  INSERT INTO spares (
    spare_code,
    spare_name,
    spare_description,
    spare_type,
    spare_status,
    price,
    quantity,
    updated_at
  )
  SELECT
    "spareCode",
    "spareName",
    "spareDescription",
    "spareType",
    "spareStatus",
    ROUND(NULLIF("price", '')::NUMERIC)::INTEGER,
    "quantity",
    "updatedAt"
  FROM jsonb_to_recordset((SELECT data FROM raw_json)) AS x(
    "spareCode" VARCHAR(50),
    "spareName" VARCHAR(100),
    "spareDescription" TEXT,
    "spareType" VARCHAR(50),
    "spareStatus" VARCHAR(50),
    "price" TEXT,
    "quantity" INTEGER,
    "updatedAt" VARCHAR(50)
  )
  ON CONFLICT (spare_code) DO NOTHING;
EOSQL
