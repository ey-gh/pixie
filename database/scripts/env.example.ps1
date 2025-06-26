# db/scrips/env.example.ps1

$env:PIXIE_ROOT         = "C:\Example\Path\Root\"
$env:PIXIE_PSQL_PATH    = "C:\Example\Path\psql.exe"

$env:PIXIE_DB_NAME      = "example_db"
$env:PIXIE_DB_USER      = "example_user"
$env:PIXIE_DB_HOST      = "example_host"

$env:PIXIE_DB_SCHEMA    = "$env:PIXIE_ROOT\path\to\schema\"
$env:PIXIE_DB_LOGS      = "$env:PIXIE_ROOT\path\to\logs\"
$env:PIXIE_DB_ERRORS    = "$env:PIXIE_ROOT\path\to\errors\"