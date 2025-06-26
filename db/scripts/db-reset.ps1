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

# SIG # Begin signature block
# MIIFcAYJKoZIhvcNAQcCoIIFYTCCBV0CAQExCzAJBgUrDgMCGgUAMGkGCisGAQQB
# gjcCAQSgWzBZMDQGCisGAQQBgjcCAR4wJgIDAQAABBAfzDtgWUsITrck0sYpfvNR
# AgEAAgEAAgEAAgEAAgEAMCEwCQYFKw4DAhoFAAQUqprZL3Fx3uwYEUp7yDAPG2/h
# ds6gggMKMIIDBjCCAe6gAwIBAgIQQzKF37x4TZ1FLpXX31uI/zANBgkqhkiG9w0B
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
# BgorBgEEAYI3AgELMQ4wDAYKKwYBBAGCNwIBFTAjBgkqhkiG9w0BCQQxFgQUbMxS
# /G/CoYL+DH0avRbWv0j4VGswDQYJKoZIhvcNAQEBBQAEggEASotiKxfDr8J1E1xU
# +ZFVLtFUs28eBPUJ4eEUvVM0M8rX51K63gBb9/JIIZ+uA3ksFD/uqDoXgd9IYz47
# qbz5OzbKUX+1RQk/IzxxeXtIfO4LvgF9VRUs7wtH9WTOpy0yJ36XQgagXnQTzPy8
# UcSbw+Lr+6S7yXpEJibQzSpv8umM8cs8A5xI5skx2NtIykknrlE/xaGO9qgJ4ceG
# 7TpHVsSmka7MtWDFAAd4fmmjRtnwDL6a85jn+5uOMwbGxxaChfWc4wPghTDZMgLt
# igFNVj0XlSq6LKlR7aAResOrKUwKRD/2sDkTQ38zI90mqYNd0svMGC1por4Xb9Pc
# 3w99Hg==
# SIG # End signature block
