# db/scripts/verify_schema.ps1

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
$db         = $env:PIXIE_DB_NAME
$user       = $env:PIXIE_DB_USER
$server     = $env:PIXIE_DB_HOST
$logs       = $env:PIXIE_DB_LOGS
$errors     = $env:PIXIE_DB_ERRORS

foreach ($dir in @($logs, $errors)) {
    if (-Not (Test-Path $dir)) {
        New-Item -ItemType Directory -Path $dir | Out-Null
    }
}

$timestamp = Get-Date -Format "yyyy-MM-dd_HH-mm-ss"
$logPath   = Join-Path $logs "verify_log_$timestamp.txt"
$errorLog  = Join-Path $errors "verify_error_$timestamp.txt"

"----- $timestamp - BEGIN SCHEMA VERIFICATION -----" | Out-File -FilePath $logPath -Encoding UTF8
"----- $timestamp - BEGIN ERRORS ------------------" | Out-File -FilePath $errorLog -Encoding UTF8

$requiredTables = @("clients", "claims", "users")
$missing = @()

foreach ($table in $requiredTables) {
    $query = "SELECT to_regclass('public.$table');"
    $result = & $psqlPath -U $user -h $server -d $db -t -c $query
    $found = $result.Trim()

    if ($found -eq "") {
        $msg = "MISSING: $table"
        Write-Host $msg
        $msg | Out-File -Append -FilePath $logPath
        $msg | Out-File -Append -FilePath $errorLog
        $missing += $table
    } else {
        $msg = "Found: $table"
        Write-Host $msg
        $msg | Out-File -Append -FilePath $logPath
    }
}

if ($missing.Count -eq 0) {
    Write-Host "All required tables found."
    "All required tables found." | Out-File -Append -FilePath $logPath
} else {
    Write-Host "Some tables are missing. See $errorLog"
    "Some tables are missing. See $errorLog" | Out-File -Append -FilePath $logPath
}
