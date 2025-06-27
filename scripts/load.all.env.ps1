param(
    [string[]]$envFiles = @(
        "../.env",
        "../database/.env.database",
        "../backend/.env.backend",
        "../frontend/.env.frontend"
    )
)

Write-Host "=== Loading Environment Variables ==="

foreach ($envFile in $envFiles) {
    if (Test-Path $envFile) {
        Write-Host "`n> Loading: $envFile"

        Get-Content $envFile | ForEach-Object {
            if ($_ -match "^\s*#") { return }
            if ($_ -match "^\s*$") { return }
            if ($_ -match "^\s*([^=]+)\s*=\s*(.+)$") {
                $key = $matches[1].Trim()
                $val = $matches[2].Trim()
                $expanded = $ExecutionContext.InvokeCommand.ExpandString($val)
                Set-Item -Path "Env:$key" -Value $expanded
                Write-Host ("  {0} = {1}" -f $key, (Get-Item -Path "Env:$key").Value)
            }
        }
    } else {
        Write-Host "`n> Skipping missing file: $envFile"
    }
}
