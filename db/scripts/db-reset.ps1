# db/scripts/reset_db.ps1

# === REQUIRED ENVIRONMENT ===
if (-not $env:PIXIE_ROOT -or 
    -not $env:PIXIE_PSQL_PATH -or 
    -not $env:PIXIE_DB_NAME -or 
    -not $env:PIXIE_DB_SCHEMA -or 
    -not $env:PIXIE_DB_HOST -or 
    -not $env:PIXIE_DB_USER -or 
    -not $env:PIXIE_DB_LOGS -or 
    -not $env:PIXIE_DB_ERRORS) {

    if (-not $env:PIXIE_ROOT) {Write-Out "Missing environment variable: $env:PIXIE_ROOT"}
    if (-not $env:PIXIE_PSQL_PATH) {Write-Out "Missing environment variable: $env:PIXIE_PSQL_PATH"}
    if (-not $env:PIXIE_DB_NAME) {Write-Out "Missing environment variable: $env:PIXIE_DB_NAME"}
    if (-not $env:PIXIE_DB_SCHEMA) {Write-Out "Missing environment variable: $env:PIXIE_DB_SCHEMA"}
    if (-not $env:PIXIE_DB_HOST) {Write-Out "Missing environment variable: $env:PIXIE_DB_HOST"}
    if (-not $env:PIXIE_DB_USER) {Write-Out "Missing environment variable: $env:PIXIE_DB_USER"}
    if (-not $env:PIXIE_DB_LOGS) {Write-Out "Missing environment variable: $env:PIXIE_DB_LOGS"}
    if (-not $env:PIXIE_DB_ERRORS) {Write-Out "Missing environment variable: $env:PIXIE_DB_ERRORS"}

    exit 1
}

$psqlPath   = $env:PIXIE_PSQL_PATH
$createdb   = $psqlPath.Replace("psql.exe", "createdb.exe")
$dropdb     = $psqlPath.Replace("psql.exe", "dropdb.exe")
$db         = $env:PIXIE_DB_NAME
$user       = $env:PIXIE_DB_USER
$server     = $env:PIXIE_DB_HOST
$logs       = $env:PIXIE_DB_LOGS
$errors     = $env:PIXIE_DB_ERRORS
$timestamp  = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logPath    = Join-Path $logs "reset_log_$timestamp.txt"
$errorLog   = Join-Path $errors "reset_error_$timestamp.txt"

foreach ($dir in @($logs, $errors)) {
    if (-Not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
}

"----- $timestamp - BEGIN RESET -----" | Out-File -FilePath $logPath -Encoding UTF8
"----- $timestamp - BEGIN ERRORS ----" | Out-File -FilePath $errorLog -Encoding UTF8

Write-Host "Dropping database $db..."
"Dropping database $db..." | Out-File -Append -FilePath $logPath
& $dropdb -U $user -h $server $db 2>> $errorLog

Write-Host "Creating database $db..."
"Creating database $db..." | Out-File -Append -FilePath $logPath
& $createdb -U $user -h $server $db 2>> $errorLog

if ($LASTEXITCODE -ne 0) {
    $err = "Failed to create database. Aborting."
    Write-Host $err
    $err | Out-File -Append -FilePath $logPath
    $err | Out-File -Append -FilePath $errorLog
    exit 1
}

"----- $(Get-Date -Format "yyyy-MM-dd HH:mm:ss") - RESET COMPLETE -----" | Out-File -Append -FilePath $logPath
Write-Host "Database reset complete."
