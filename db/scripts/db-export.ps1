# db/scripts/export_schema.ps1

# === FAIL FAST ON UNHANDLED ERRORS ===
$ErrorActionPreference = "Stop"

# === REQUIRED ENVIRONMENT ===
if (-not $env:PIXIE_ROOT -or 
    -not $env:PIXIE_PSQL_PATH -or 
    -not $env:PIXIE_DB_NAME -or 
    -not $env:PIXIE_DB_SCHEMA -or 
    -not $env:PIXIE_DB_HOST -or 
    -not $env:PIXIE_DB_USER -or 
    -not $env:PIXIE_DB_LOGS -or 
    -not $env:PIXIE_DB_ERRORS) {

    if (-not $env:PIXIE_ROOT)       { Write-Host "Missing environment variable: PIXIE_ROOT" }
    if (-not $env:PIXIE_PSQL_PATH)  { Write-Host "Missing environment variable: PIXIE_PSQL_PATH" }
    if (-not $env:PIXIE_DB_NAME)    { Write-Host "Missing environment variable: PIXIE_DB_NAME" }
    if (-not $env:PIXIE_DB_SCHEMA)  { Write-Host "Missing environment variable: PIXIE_DB_SCHEMA" }
    if (-not $env:PIXIE_DB_HOST)    { Write-Host "Missing environment variable: PIXIE_DB_HOST" }
    if (-not $env:PIXIE_DB_USER)    { Write-Host "Missing environment variable: PIXIE_DB_USER" }
    if (-not $env:PIXIE_DB_LOGS)    { Write-Host "Missing environment variable: PIXIE_DB_LOGS" }
    if (-not $env:PIXIE_DB_ERRORS)  { Write-Host "Missing environment variable: PIXIE_DB_ERRORS" }

    exit 1
}

# === CONFIGURATION ===
$pgDumpPath     = $env:PIXIE_PSQL_PATH.Replace("psql.exe", "pg_dump.exe")
$db             = $env:PIXIE_DB_NAME
$user           = $env:PIXIE_DB_USER
$server         = $env:PIXIE_DB_HOST
$logs           = $env:PIXIE_DB_LOGS
$errors         = $env:PIXIE_DB_ERRORS
$timestamp      = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$exports        = Join-Path $env:PIXIE_ROOT "db\exports"
$exportPath     = Join-Path $exports "schema_export_$timestamp.sql"
$logPath        = Join-Path $logs "export_log_$timestamp.txt"
$errorLog       = Join-Path $errors "export_error_$timestamp.txt"

# === ENSURE OUTPUT DIRECTORIES EXIST ===
foreach ($dir in @($logs, $errors, $exports)) {
    if (-not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
}

# === LOG HEADERS ===
"----- $timestamp - BEGIN DATABASE EXPORT -----" | Out-File -FilePath $logPath -Encoding UTF8
"----- $timestamp - BEGIN EXPORT ERRORS ------------" | Out-File -FilePath $errorLog -Encoding UTF8

# === EXECUTE EXPORT ===
Write-Host "Exporting schema to $exportPath..."
"Exporting schema to $exportPath..." | Out-File -Append -FilePath $logPath

& $pgDumpPath -U $user -h $server --schema-only --no-owner --file=$exportPath $db *>> $logPath

# === HANDLE RESULT ===
if ($LASTEXITCODE -eq 0) {
    Write-Host "Export complete"
    "Export complete" | Out-File -Append -FilePath $logPath
} else {
    $err = "Export failed"
    Write-Host $err
    $err | Out-File -Append -FilePath $logPath
    $err | Out-File -Append -FilePath $errorLog
}