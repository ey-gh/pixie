# db/scripts/env.dev.ps1

$env:PIXIE_ROOT         = "C:\Users\e\dev\pixie"
$env:PIXIE_PSQL_PATH    = "C:\Program Files\PostgreSQL\17\bin\psql.exe"

$env:PIXIE_DB_NAME      = "pixie-db-dev"
$env:PIXIE_DB_USER      = "postgres"
$env:PIXIE_DB_HOST      = "localhost"

$env:PIXIE_DB_SCHEMA    = "$env:PIXIE_ROOT\db\schema"
$env:PIXIE_DB_LOGS      = "$env:PIXIE_ROOT\db\logs"
$env:PIXIE_DB_ERRORS    = "$env:PIXIE_ROOT\db\errors"

Write-Host "Environment variables loaded:"
"PIXIE_ROOT         = $env:PIXIE_ROOT"
"PIXIE_PSQL_PATH    = $env:PIXIE_PSQL_PATH"
"PIXIE_DB_NAME      = $env:PIXIE_DB_NAME"
"PIXIE_DB_USER      = $env:PIXIE_DB_USER"
"PIXIE_DB_HOST      = $env:PIXIE_DB_HOST"
"PIXIE_DB_SCHEMA    = $env:PIXIE_DB_SCHEMA"
"PIXIE_DB_LOGS      = $env:PIXIE_DB_LOGS"
"PIXIE_DB_ERRORS    = $env:PIXIE_DB_ERRORS"