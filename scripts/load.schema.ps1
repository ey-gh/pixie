# Determine absolute path to schema/ folder
$schemaDir = Join-Path $PSScriptRoot "..\database\schema"

# Sanity check
if (-not (Test-Path $schemaDir)) {
    Write-Error "Schema directory not found: $schemaDir"
    exit 1
}

Write-Host "⏳ Loading schema from: $schemaDir"

# Stream all SQL files in order into docker
Get-ChildItem -Path $schemaDir -Filter *.sql |
    Sort-Object Name |
    Get-Content |
    docker exec -i pixie-db psql -q -U postgres -d pixie-db-dev

if ($LASTEXITCODE -eq 0) {
    Write-Host "Schema loaded into Docker container 'pixie-db'."
} else {
    Write-Error "Failed to load schema."
}
