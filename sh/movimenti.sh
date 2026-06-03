#!/usr/bin/env bash

set -e # exit if a commands returns a non-zero value

echo "🤑 Create table movimenti"

DB="movimenti.db"

sqlite3 "${DB}" <<'EOF'
CREATE TABLE IF NOT EXISTS movimenti (
    tipo TEXT,
    prodotto TEXT,
    data_inizio TEXT,
    data_completamento TEXT,
    descrizione TEXT,
    importo REAL,
    costo REAL,
    valuta TEXT,
    stato TEXT,
    saldo REAL
);

CREATE UNIQUE INDEX IF NOT EXISTS idx_movimenti_unique
ON movimenti (data_inizio, data_completamento, importo);
EOF

for csv in *.csv; do
    echo "🤑 import ${csv}"

    sqlite3 "${DB}" <<EOF
DROP TABLE IF EXISTS tmp_import;

CREATE TEMP TABLE tmp_import (
    tipo TEXT,
    prodotto TEXT,
    data_inizio TEXT,
    data_completamento TEXT,
    descrizione TEXT,
    importo REAL,
    costo REAL,
    valuta TEXT,
    stato TEXT,
    saldo REAL
);

.mode csv
.import --skip 1 "${csv}" tmp_import

SELECT 'Duplicati:';

SELECT *
FROM tmp_import t
JOIN movimenti m
ON (
    t.data_inizio = m.data_inizio
    AND t.data_completamento = m.data_completamento
    AND t.importo = m.importo
);

SELECT 'Inserting...';

INSERT OR IGNORE INTO movimenti
SELECT * FROM tmp_import;
EOF

done

echo "🤑 All operations completed successfully"
