# db/scripts/db_import.ps1

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

# === CONFIGURATION ===
$psqlPath   = $env:PIXIE_PSQL_PATH
$db         = $env:PIXIE_DB_NAME
$user       = $env:PIXIE_DB_USER
$server     = $env:PIXIE_DB_HOST
$schema     = $env:PIXIE_DB_SCHEMA
$logs       = $env:PIXIE_DB_LOGS
$errors     = $env:PIXIE_DB_ERRORS
$timestamp  = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logPath    = Join-Path $logs "import-logs_$timestamp.txt"
$errorLog   = Join-Path $errors "import-errors_$timestamp.txt"
$successes  = @()
$failures   = @()

# === ENSURE LOG AND ERROR FOLDERS EXIST ===
foreach ($dir in @($logs, $errors)) {
    if (-Not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
}

# === BEGIN LOGGING ===
"----- $timestamp - BEGIN DATABASE IMPORT -----" | Out-File -FilePath $logPath -Encoding UTF8
"----- $timestamp - BEGIN IMPORT ERRORS --------------" | Out-File -FilePath $errorLog -Encoding UTF8

# === LOAD SQL FILES (RECURSIVE) ===
try {
    $sqlFiles = Get-ChildItem -Path $schema -Recurse -Filter *.sql | Sort-Object FullName
} catch {
    $err = "ERROR: Could not read from $schema"
    Write-Host $err
    $err | Out-File -Append -FilePath $logPath
    $err | Out-File -Append -FilePath $errorLog
    exit 1
}

# === EXECUTE SQL FILES ===
foreach ($file in $sqlFiles) {
    $msg = "Running $($file.FullName)..."
    Write-Host $msg
    $msg | Out-File -Append -FilePath $logPath

    & $psqlPath -U $user -h $server -d $db --set ON_ERROR_STOP=1 -f $file.FullName *>> $logPath

    if ($LASTEXITCODE -ne 0) {
        $err = "ERROR in $($file.Name). Halting."
        Write-Host $err
        $err | Out-File -Append -FilePath $logPath
        $err | Out-File -Append -FilePath $errorLog
        $failures += $file.Name
        break
    } else {
        $ok = "Completed $($file.Name)"
        Write-Host $ok
        $ok | Out-File -Append -FilePath $logPath
        $successes += $file.Name
    }
}

# === SUMMARY ===
"" | Out-File -Append -FilePath $logPath
"----- IMPORT SUMMARY -----" | Out-File -Append -FilePath $logPath
"Successes:" | Out-File -Append -FilePath $logPath
$successes | ForEach-Object { "  $_" | Out-File -Append -FilePath $logPath }

if ($failures.Count -gt 0) {
    "Failures:" | Out-File -Append -FilePath $logPath
    $failures | ForEach-Object { "  $_" | Out-File -Append -FilePath $logPath }
    "Completed with errors. See: $errorLog" | Out-File -Append -FilePath $logPath
    Write-Host "Import finished with errors. See $errorLog"
    exit 1
} else {
    "All scripts completed successfully." | Out-File -Append -FilePath $logPath
    Write-Host "All scripts completed successfully."
}