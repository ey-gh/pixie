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
# SIG # Begin signature block
# MIIFcAYJKoZIhvcNAQcCoIIFYTCCBV0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUSFmHEKesTYGpUz6H+ROCYioA
# h+egggMKMIIDBjCCAe6gAwIBAgIQQzKF37x4TZ1FLpXX31uI/zANBgkqhkiG9w0B
# AQsFADAbMRkwFwYDVQQDDBBEZXYgQ29kZSBTaWduaW5nMB4XDTI1MDYyNjEyMjU0
# NVoXDTI2MDYyNjEyNDU0NVowGzEZMBcGA1UEAwwQRGV2IENvZGUgU2lnbmluZzCC
# ASIwDQYJKoZIhvcNAQEBBQADggEPADCCAQoCggEBAMGghZiagBDWRbuo9DOJ1inJ
# jENw5wIsjMIA2g27RkBp43QKWSQAnBS3+7z6JO6Afw0WrgKOaV7vEu4n2gAz9Ctl
# phjE+BsjRSifz2jTaDtEKQQsiOIWRQucdzM1tWcPV/H49Wvexo0RNKvjCoOsxaU1
# d2Ey0XoLxcn1kY+ABwALknG9PDDGXhRZfcRRXyZhfdOoSayDWtRqzSijsaRBuTOd
# iO6y5OpVKd7d2FQhv7h70PaOAkiytdZLCs+NhmiXFzsI83DPywVPOYGLzedg5mSC
# vPFEyqAKzvnEsutmBCy0LVkLAsWs+tqNrxzUONh9eXR5EfZETeHeEEP0tckz/iUC
# AwEAAaNGMEQwDgYDVR0PAQH/BAQDAgeAMBMGA1UdJQQMMAoGCCsGAQUFBwMDMB0G
# A1UdDgQWBBS+W9K7Pf69ou3e01AR9lcc/QNpWzANBgkqhkiG9w0BAQsFAAOCAQEA
# OOpc2QSSXoE8BEF6NPeDly2I5yyLNkyRkq8EoCVB6tVIiVC/O5FbaPHdUR13wZj0
# 5/A5TTsMYBzbPVnDm1CMX28/FOGPse547dMGoa9/UlqmnuNnxYE24xHe/qsewocY
# kERh7/EIPx5L0n3TmF0A/hh5WsC4w2orrEvx/3AvhvK7hoI/GLg7+d9h5SASpIWQ
# 2pZm4NT1TA/7A83fMYdz9NbXfcO6tReheV91SbjdSF3KyMSOyDi6rbkhcK6OId7X
# jQQ67NT+BkoSjS3wtVt3tpMTL9zygNQFTprQYTYbGYRP8ofCqcJmr0A2IksmYHuU
# 7cUggjU9sWePKIg6b7VstjGCAdAwggHMAgEBMC8wGzEZMBcGA1UEAwwQRGV2IENv
# ZGUgU2lnbmluZwIQQzKF37x4TZ1FLpXX31uI/zAJBgUrDgMCGgUAoHgwGAYKKwYB
# BAGCNwIBDDEKMAigAoAAoQKAADAZBgkqhkiG9w0BCQMxDAYKKwYBBAGCNwIBBDAc
# BgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUKt0N
# MuKjA9C1gV8pCa1ssRbf2zcwDQYJKoZIhvcNAQEBBQAEggEAr9w+N+j5JRWF1r2m
# 9s/lDfTi3y2sae1ft/QceV7dGK0jEs2cbidmm1I6YjUYQvkeMEojs7xf1HdrvwD/
# 4Aytfn6YtviZC/6ncpQVY5FOgEzUdEV2JfaomfgG+bnkm3FwCcvvsLQ7knWc0RkX
# nujFNGjIcqOsDF9b8407iVvJNoljGh0WRX4TtTTiRBBK5LkRBk3YQVt7XVIKRVcW
# YHg23nUh/PUww46w1341O1dsFMMxQPXpfdkbxy4BPrYxDUs13uYVEvSCX7AKPqrB
# ulE7ij/LIHO6XCLg5uF367wKD0gX/LlADrxi8dH/5Cvp1m1jcIhnPLHuR7SAIjD6
# UpiUXw==
# SIG # End signature block
